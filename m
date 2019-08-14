Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67A82C32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 15:09:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1CE4A2083B
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 15:09:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="x2n6+rP6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1CE4A2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A4B576B000A; Wed, 14 Aug 2019 11:09:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FA306B000C; Wed, 14 Aug 2019 11:09:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 90F986B000D; Wed, 14 Aug 2019 11:09:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0157.hostedemail.com [216.40.44.157])
	by kanga.kvack.org (Postfix) with ESMTP id 6FDC66B000A
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 11:09:41 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 26A63180AD7C3
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 15:09:41 +0000 (UTC)
X-FDA: 75821367762.20.pin56_375cb59fb5e01
X-HE-Tag: pin56_375cb59fb5e01
X-Filterd-Recvd-Size: 6678
Received: from mail-lj1-f196.google.com (mail-lj1-f196.google.com [209.85.208.196])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 15:09:40 +0000 (UTC)
Received: by mail-lj1-f196.google.com with SMTP id e24so8426232ljg.11
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 08:09:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=date:from:to:cc:subject:message-id:mail-followup-to:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=2ptfAgVpyIEhhkDUXUHOQeIgB7V3ChTfM7YuAb134Kg=;
        b=x2n6+rP6ZwrFCjfm8bFO/Vk4gMraybEkDtn/pwBnfQQjn651Lm6f83/MXyyR8JDaJE
         0tRK/p9cifp44E0FTnkOFanairQJNzX1c1zeImZ08ypWdY+O3vhaXoleBFSqBlh1/WyQ
         3nw5aLY8qaAOkW4Kr27WJdta4q7KRfmbDPzyjCe94MN8cML68DixxuMWmWQZsCDEP9vU
         WZrbCO9PrBo1mpyeFxRE6BB+JsO9MV5inELKKQU+MM8jr/Dd+EPbD4squSjv2Euk0nKK
         kgtq7iRzdyBwtJyGbcbx6KhvBupL4J3XvuPS4oMY2Ri/cWI5dK+TbVzUVWhCwFsKuonO
         DJ6A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id
         :mail-followup-to:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=2ptfAgVpyIEhhkDUXUHOQeIgB7V3ChTfM7YuAb134Kg=;
        b=EdwG2zk6SDEl91N1FncK1NvC7N0pnAn4u4eQ/uCE5i3cVx9SLXL2fnYKMn6Zj0YL4R
         CazJJx6ze7WFF51IH6hpviHABdf9B3lJjB54+isqghq4i5CGAsos64uD+b+Z1h4ABJl/
         0YZjPW3HDl5W4a0fmM/g3hc6iOpWeUHwxB97mMKr39knSoUYnWKnVFah1+dlGni7XkAB
         bzowRswis117GA7Xkh0mD443QOJkNi3FNdPGzAshr3P7crE4W+7fuZlkUqKP8UuwBOGA
         TibPAEt7L7BL36SQznztKJyCd/wvk/NuvO7lBxDt+rG0Jh2f+Q0xKV8oUQQMnAzvx8Rd
         7KeA==
X-Gm-Message-State: APjAAAWcdP6NKh4/vbsQ3Cndd+LfzBWoUgqGAoK7mGDsllFRZznx4h1r
	4VzN5lT4vFd9hD9v9CDxaGzSHA==
X-Google-Smtp-Source: APXvYqyAM8eXnr+Jy6s24b158nlo/qNRMKZlplURPgkyhCKBGAc5pooN4Mik7Peninx/2IsQdmdO8w==
X-Received: by 2002:a2e:81c3:: with SMTP id s3mr162966ljg.70.1565795378768;
        Wed, 14 Aug 2019 08:09:38 -0700 (PDT)
Received: from khorivan (168-200-94-178.pool.ukrtel.net. [178.94.200.168])
        by smtp.gmail.com with ESMTPSA id l8sm2347lja.38.2019.08.14.08.09.37
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Aug 2019 08:09:38 -0700 (PDT)
Date: Wed, 14 Aug 2019 18:09:36 +0300
From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: bjorn.topel@intel.com, linux-mm@kvack.org, xdp-newbies@vger.kernel.org,
	netdev@vger.kernel.org, bpf@vger.kernel.org,
	linux-kernel@vger.kernel.org, ast@kernel.org,
	magnus.karlsson@intel.com
Subject: Re: [PATCH v2 bpf-next] mm: mmap: increase sockets maximum memory
 size pgoff for 32bits
Message-ID: <20190814150934.GD4142@khorivan>
Mail-Followup-To: Andrew Morton <akpm@linux-foundation.org>,
	bjorn.topel@intel.com, linux-mm@kvack.org,
	xdp-newbies@vger.kernel.org, netdev@vger.kernel.org,
	bpf@vger.kernel.org, linux-kernel@vger.kernel.org, ast@kernel.org,
	magnus.karlsson@intel.com
References: <20190812113429.2488-1-ivan.khoronzhuk@linaro.org>
 <20190812124326.32146-1-ivan.khoronzhuk@linaro.org>
 <20190812141924.32136e040904d0c5a819dcb1@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190812141924.32136e040904d0c5a819dcb1@linux-foundation.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 12, 2019 at 02:19:24PM -0700, Andrew Morton wrote:

Hi, Andrew

>On Mon, 12 Aug 2019 15:43:26 +0300 Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org> wrote:
>
>> The AF_XDP sockets umem mapping interface uses XDP_UMEM_PGOFF_FILL_RING
>> and XDP_UMEM_PGOFF_COMPLETION_RING offsets. The offsets seems like are
>> established already and are part of configuration interface.
>>
>> But for 32-bit systems, while AF_XDP socket configuration, the values
>> are to large to pass maximum allowed file size verification.
>> The offsets can be tuned ofc, but instead of changing existent
>> interface - extend max allowed file size for sockets.
>
>
>What are the implications of this?  That all code in the kernel which
>handles mapped sockets needs to be audited (and tested) for correctly
>handling mappings larger than 4G on 32-bit machines?  Has that been

That's to allow only offset to be passed, mapping length is less than 4Gb.
I have verified all list of mmap for sockets and all of them contain dummy
cb sock_no_mmap() except the following:

xsk_mmap()
tcp_mmap()
packet_mmap()

xsk_mmap() - it's what this fix is needed for.
tcp_mmap() - doesn't have obvious issues with pgoff - no any references on it.
packet_mmap() - return -EINVAL if it's even set.


>done?  Are we confident that we aren't introducing user-visible buggy
>behaviour into unsuspecting legacy code?
>
>Also...  what are the user-visible runtime effects of this change?
>Please send along a paragraph which explains this, for the changelog.
>Does this patch fix some user-visible problem?  If so, should be code
>be backported into -stable kernels?
It should go to linux-next, no one has been using it till this patch
with 32 bits as w/o this fix af_xdp sockets can't be used at all.
It unblocks af_xdp socket usage for 32bit systems.


That's example of potential next commit message:
Subject: mm: mmap: increase sockets maximum memory size pgoff for 32bits

The AF_XDP sockets umem mapping interface uses XDP_UMEM_PGOFF_FILL_RING
and XDP_UMEM_PGOFF_COMPLETION_RING offsets.  These offsets are established
already and are part of the configuration interface.

But for 32-bit systems, using AF_XDP socket configuration, these values
are too large to pass the maximum allowed file size verification.  The
offsets can be tuned off, but instead of changing the existing interface,
let's extend the max allowed file size for sockets.

No one has been using it till this patch with 32 bits as w/o this fix
af_xdp sockets can't be used at all, so it unblocks af_xdp socket usage
for 32bit systems.

All list of mmap cbs for sockets were verified on side effects and
all of them contain dummy cb - sock_no_mmap() at this moment, except the
following:

xsk_mmap() - it's what this fix is needed for.
tcp_mmap() - doesn't have obvious issues with pgoff - no any references on it.
packet_mmap() - return -EINVAL if it's even set.




Is it ok to be replicated in PATCH v2 or this explanation is enough here
to use v1?

-- 
Regards,
Ivan Khoronzhuk

