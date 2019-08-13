Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 866A5C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 13:06:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B336206C2
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 13:06:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rWi6khMG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B336206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D32256B0005; Tue, 13 Aug 2019 09:06:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE2536B0006; Tue, 13 Aug 2019 09:06:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD11D6B0007; Tue, 13 Aug 2019 09:06:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0137.hostedemail.com [216.40.44.137])
	by kanga.kvack.org (Postfix) with ESMTP id 962E06B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:06:35 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 3974C6115
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 13:06:35 +0000 (UTC)
X-FDA: 75817428750.01.sea19_568e4977b8739
X-HE-Tag: sea19_568e4977b8739
X-Filterd-Recvd-Size: 4124
Received: from mail-qk1-f195.google.com (mail-qk1-f195.google.com [209.85.222.195])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 13:06:34 +0000 (UTC)
Received: by mail-qk1-f195.google.com with SMTP id m10so4361571qkk.1
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 06:06:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=dPePM4b7Ly9h58EwlKTM619AD4xFQbyhPDiSia2EM2U=;
        b=rWi6khMGtrbzvWBFMuKOaneDwVBFkNzEA+bV4ShPlu9hL6T+L7nBa8gQDqbg7wmj9l
         A3KIk979T6sWVsHhW4Fm/VaENm/Pi3YN9D3TaMbA39C3bNT0UdMZbtzfgFwX8I773l/c
         3RsG9coxViRKwz3yQGebHYpzOEt6b6aR6vvSzsRAH3RbtDY1HDGaMX6ehk0FlP7sff7C
         ekZDrrVWdki+9s23mAN9i+bmtgZqgXojixJSkXBwq8Efoir2sZDaba3uPvCZhlRSyqIY
         CrG+1B1yVaV4pE4euqUVZufBvyCGY3HP9VT9vlaNLTbPJwVsmhEc0FPeovlP8bvtYcsV
         nWyw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:reply-to
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=dPePM4b7Ly9h58EwlKTM619AD4xFQbyhPDiSia2EM2U=;
        b=HHehLwfpAK+g1b3EkKuRqAjii48imy1PQXWYm+WxjxWZ7Vb4qwtrOXQxoWb/R4Duvg
         lolFc32f4x1mYz7+QBWs7+EknCpT6VY+78SHhiR5pv8lP+s0a8OO9WyQEEE4HXvAk1XI
         tzrDnErPZTEa7I7qe6K2KxIUnTLCPxqimGkNuY7PVgQBXaujFZcFhBH4khijxxQNq7IJ
         SrB1uupHvTc6K928MrDQxh/emwP2toeK6g2Tk6n0lL+1uZ4q12lAbcR8t6Bj0ULL84Ym
         9vMx07EGuVBjduIYTKdoLfhhNepTXQOyYu6FArR72wI8QNG9VW55SOx4ib8S1klxzTNX
         JcxA==
X-Gm-Message-State: APjAAAU4ikuUjYg4mrdCOndrQ1P+1ITE0s/uFTue57IxJhmXsu/nHS7i
	CbOnHFgKSCMPmbXpypJCuI8=
X-Google-Smtp-Source: APXvYqxoPh7Vwka4FMUE4K0pxkSvpnkQ2+EVcB3voDPInyDih0g+8JHM7XendeivsUYRonHZ4s/q+w==
X-Received: by 2002:ae9:c00c:: with SMTP id u12mr23656206qkk.75.1565701594164;
        Tue, 13 Aug 2019 06:06:34 -0700 (PDT)
Received: from localhost (tripoint.kitware.com. [66.194.253.20])
        by smtp.gmail.com with ESMTPSA id z5sm45834363qti.80.2019.08.13.06.06.33
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 13 Aug 2019 06:06:33 -0700 (PDT)
Date: Tue, 13 Aug 2019 09:06:33 -0400
From: Ben Boeckel <mathstuf@gmail.com>
To: Alison Schofield <alison.schofield@intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv2 25/59] keys/mktme: Preparse the MKTME key payload
Message-ID: <20190813130633.GB9079@rotor.kitware.com>
Reply-To: mathstuf@gmail.com
References: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
 <20190731150813.26289-26-kirill.shutemov@linux.intel.com>
 <20190805115819.GA31656@rotor>
 <20190805203102.GA7592@alison-desk.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190805203102.GA7592@alison-desk.jf.intel.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 05, 2019 at 13:31:02 -0700, Alison Schofield wrote:
> It's not currently checked, but should be. 
> I'll add it as shown above.
> Thanks for the review,

Thanks. Seeing how this works elsewhere now, feel free to add my review
with the proposed check to the new patch.

Reviewed-by: Ben Boeckel <mathstuf@gmail.com>

--Ben

