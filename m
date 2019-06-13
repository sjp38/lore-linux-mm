Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6A1DC31E47
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 03:05:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3EBD0215EA
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 03:05:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="gf4dv7WU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3EBD0215EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EFC66B0007; Wed, 12 Jun 2019 23:05:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89FE76B000C; Wed, 12 Jun 2019 23:05:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7907A6B000D; Wed, 12 Jun 2019 23:05:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 298716B0007
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 23:05:57 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id q14so8200215wrm.23
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 20:05:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=5347sLkcqdCaDr4KbIIf3bKPXQaQU7AVUw40AwlLk0E=;
        b=n22ROL6i1k9SCjzRjoxkn3l3KEHviRxCDIY0tFXMlV01HvZqEACznk916LbDqKKiMM
         NoH4JIzgqZA2PQPx2bGfxYaSFgKKEpE8/MOMIAo4SOguchNxKu3+dvX7ywvx2tlP1sch
         3xhiQb9aSyGETD6BFIFqdDQ+c7Omn/OmkoGkQXkrnQzA4s94ZXL1j4izE7BGHXyyHXcQ
         6ItZmJNZTqpr6b7W7Pk2aQ6DpHkVXxXXmWV1h/sEdN+10xs8/ZgMA+3iSThTzGo3Gd6/
         wOMZq9aDcbIFqvLoedQuPTy+lir22HggOW3sQ1L9fQ1HT5THW+/tO3Lt90d8befafUS2
         KfGw==
X-Gm-Message-State: APjAAAXXDhA5pv6rdu/OgYvYkKTbXuw3VdtOCLSWVDRS0xnhbIZtazsM
	gUy7XIHCdqvpUKdHEH5TeaKZc278dOxAzXjV/rTy5zWuz8C2wun59i/3HqiQne17639RJ7i8IBv
	M2f0ZNH/SuwJ8txeYWDel4P91bFShVe3reO6YVyhzZYEZrhG29kpKuuw7vRcX2t0Twg==
X-Received: by 2002:a5d:618d:: with SMTP id j13mr34554978wru.195.1560395156607;
        Wed, 12 Jun 2019 20:05:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTVr/Xhg5h7lQ+aOyBs9wZrq7dfs/3/TbHsLUigX86eZ1HOXWqMMTTDAE/yhN5pP49PcJc
X-Received: by 2002:a5d:618d:: with SMTP id j13mr34554939wru.195.1560395155773;
        Wed, 12 Jun 2019 20:05:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560395155; cv=none;
        d=google.com; s=arc-20160816;
        b=K+tiGGsFrB1A2cPfDQRmJ3SYwF38WMsZuXhQ05tceLBqj3FQxjDKKGSPIhhLJy0sBY
         0nCrqx0nVy10hy9FqWAEbqAuihGqpmOyL/FfG2m1B9k1oaurUXTNexWTxtJtUNK1ezLm
         EFOGap8WRenIaD0O6r/w0Athbzy3Xd4RuKEiqyK1s02g/S0VI0EOlf51pthHhqc+lo1B
         kys0YQ/pVwZ1bXizhmZXkeRjv9lbWEinuNOUFwCzEJSNnv33d48C2Ind0bq8ZnwYgyjo
         bxi0qdMg/NWj21nvb9WnLCMMlahr1HUJGlbe/G2oB8Zi2cyB2R6wUStgsdwcep71urD5
         5BIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=5347sLkcqdCaDr4KbIIf3bKPXQaQU7AVUw40AwlLk0E=;
        b=IW+9s8AYtmOC+EMw2vI+24fzgt2RGgiASRdYV65vjbQ9RavkZduE4nqVIBe4RQAafg
         K6maTk0ALzIevD2iZP1e1A5zKiFGF/tRZ1vSBDkkE/3+/g5n7ggz/tb3WtynZ0ynIB4j
         tXhjq4qCw61vQsOcpp9lPg2o05Dtw9RuAz/dltl6HuBArb3MwWcOtxLRZeAW28Gbup/O
         a1D3BD9OCSYXEHjuX/KTYFMv3BLrAJv2DYk4ZOEvLyzu97Tw7MvwFrEJaVoO//OmvfOC
         HVOjgVKuQNlHRTJICGAHWnKcGzlW+xV5gAU2bB+pGTxZwGmNLUNOVevJFTKmVQOIT4Zt
         sweQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=gf4dv7WU;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id b18si1375605wrj.191.2019.06.12.20.05.55
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 12 Jun 2019 20:05:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=gf4dv7WU;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:Subject:Sender
	:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=5347sLkcqdCaDr4KbIIf3bKPXQaQU7AVUw40AwlLk0E=; b=gf4dv7WU5lUnCVxWX1b/VbhuEP
	RpAMKwYyUlhgcAdDBmtQ/bz/ehU3elbdJn89YliwF//sPf0+wbq8mbjoMZbkAAQy3GEUTYilX4iSj
	k/MtsOknTvg2JkzcbSuGPMoJIAd1IqE+0bhPaUj7Ck/jBLsepF1XEmo5T3V4WLhxVkr261JgfaI+q
	kJdtOMZfu7WKBScGQVBpA4dS8b+VasmQTV9rhm1DmyISlPeT+ImRMVI4LVCJpBHXKH56hgyQZ+xL8
	8Mm8BTD5aVCrnkDcvN3rqEi+H2BBxYlZt6vaok0WqL/4pL/2cGXo4h4qLmCehl6qYrFBo+IjcXnE5
	8GXZHODg==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=dragon.dunlab)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbG3Y-0006L6-IB; Thu, 13 Jun 2019 03:05:40 +0000
Subject: Re: mmotm 2019-06-11-16-59 uploaded (ocfs2)
To: Andrew Morton <akpm@linux-foundation.org>
Cc: broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au,
 linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 mm-commits@vger.kernel.org, ocfs2-devel@oss.oracle.com,
 Mark Fasheh <mark@fasheh.com>, Joel Becker <jlbec@evilplan.org>,
 Joseph Qi <joseph.qi@linux.alibaba.com>
References: <20190611235956.4FZF6%akpm@linux-foundation.org>
 <492b4bcc-4760-7cbb-7083-9f22e7ab4b82@infradead.org>
 <20190612181813.48ad05832e05f767e7116d7b@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <a412fca5-7204-7001-cc1a-f620ea6f64bd@infradead.org>
Date: Wed, 12 Jun 2019 20:05:36 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190612181813.48ad05832e05f767e7116d7b@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/12/19 6:18 PM, Andrew Morton wrote:
> On Wed, 12 Jun 2019 07:15:30 -0700 Randy Dunlap <rdunlap@infradead.org> wrote:
> 
>> On 6/11/19 4:59 PM, akpm@linux-foundation.org wrote:
>>> The mm-of-the-moment snapshot 2019-06-11-16-59 has been uploaded to
>>>
>>>    http://www.ozlabs.org/~akpm/mmotm/
>>>
>>> mmotm-readme.txt says
>>>
>>> README for mm-of-the-moment:
>>>
>>> http://www.ozlabs.org/~akpm/mmotm/
>>>
>>> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
>>> more than once a week.
>>
>>
>> on i386:
>>
>> ld: fs/ocfs2/dlmglue.o: in function `ocfs2_dlm_seq_show':
>> dlmglue.c:(.text+0x46e4): undefined reference to `__udivdi3'
> 
> Thanks.  This, I guess:
> 
> --- a/fs/ocfs2/dlmglue.c~ocfs2-add-locking-filter-debugfs-file-fix
> +++ a/fs/ocfs2/dlmglue.c
> @@ -3115,7 +3115,7 @@ static int ocfs2_dlm_seq_show(struct seq
>  		 * otherwise, only dump the last N seconds active lock
>  		 * resources.
>  		 */
> -		if ((now - last) / 1000000 > dlm_debug->d_filter_secs)
> +		if (div_u64(now - last, 1000000) > dlm_debug->d_filter_secs)
>  			return 0;
>  	}
>  #endif
> 
> review and test, please?
> 

Builds for me.  Thanks.

Acked-by: Randy Dunlap <rdunlap@infradead.org> # build-tested


-- 
~Randy

