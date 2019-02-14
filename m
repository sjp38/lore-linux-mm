Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E6F8C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 07:25:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B7C6222A1
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 07:25:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YGJvCBCU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B7C6222A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF2D48E0002; Thu, 14 Feb 2019 02:25:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA3358E0001; Thu, 14 Feb 2019 02:25:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B93B48E0002; Thu, 14 Feb 2019 02:25:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 77A3B8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 02:25:32 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id 71so3655526plf.19
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 23:25:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=hj2BGzvLaj4ffNSdVIGsQXgGpVC038Ikx4EcicJeqY4=;
        b=cjocLLoK5NoZ2S3myg/vqea1StYysfUFp1WYEH83AruSLEoaHCeluYVTCjBXeTYvqz
         O3AYUGPiiSicJxGTWgIVQcBmkXGsQ2EM7XY+/ikStVZcxVxGrcQI9kkDPtSjaAuci4ZZ
         n0/SfoEx/13IEfQJdSPUlf6PXtI7f3Hg+fqsLZopv0c7m5xeVMz3AphpBKQP3eLI+SKj
         vIQPOxWvET+Z1six6x3qZtFuz1d/ciZjdU1kdJ5ND+CDx4IzUCQ5tLrTy887jhgal4Xa
         /SUcSr4v3yak/t8RfMPOZXZqRn77YpolJ5GLiHCU9wEYAbpNF4WGvxMuRSjq/TkP5vv/
         BoOw==
X-Gm-Message-State: AHQUAuaLI26Ii9ttT8lh4gnQ/3RUerI13c58+3SVfCrL+FnL6kWplyyN
	DW7OLeQ8WftXueOtikSFZs2BL0RxqFO3HOwS18DLhUYLfXPND8CPfoB/1Rq0y3zTB78Vuvjf2Mq
	ISYCOAamNp7xvb4sfdivseNw0O1tVqY2pbZBYn+fMiR+0cI8C4ZM8qEyjYoRnDvv3CjcYfMj1g7
	61E+P9OEmMkmm8f0C/FGvG2Pn+Lzx0ztW1sAJpUDxb4l772iZ96fVX77wlv+pVx34+1Yyzo42iB
	xN0oQWD2c8xbmNeO3uEMJWxOI/BlmZ/qS5bUDu6kAHdZ0GJ7O6wq6ptVPezqGICpzSHm2Rd7PBw
	9b4apc74CbXkPRWOLXRBBmbiRPGcKa9snsRKC+VV/cVGcFDk4sNP7qRK2j00w0gRWPkBpR+E1A=
	=
X-Received: by 2002:a62:4188:: with SMTP id g8mr2614742pfd.205.1550129132156;
        Wed, 13 Feb 2019 23:25:32 -0800 (PST)
X-Received: by 2002:a62:4188:: with SMTP id g8mr2614647pfd.205.1550129130547;
        Wed, 13 Feb 2019 23:25:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550129130; cv=none;
        d=google.com; s=arc-20160816;
        b=auQxj8D/OMPAd8HnBDPikOB4xeKmuZ2xoNLR9tNHp7R7O0eOnCFXWeY7jmyH2YC8Xo
         tsjNN23b521eKWsbbS0Hl3SuMUP7FzE+8QWnQLUgQxjobVYfS4On36+AVW5kk5r8vukY
         MHdxc8o66YywnaO64XgYbYO9qainuvlKkUbKD2Tl1SjOMIx8AfYEkG2AMWirrT1Yqknt
         pooLRUQcNt8I9QRY2PiurRaQMFFHa+/DT/efNJuI8G+lV4+f5Z2LN4izH3Ss2UkM2zVb
         bBHXueLqiYJw1KW81Pm1XdlxW5h3918Zv+cAEyqoL2caiV5YS6NV2j9UO2kdINGmlEzr
         r0ZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=hj2BGzvLaj4ffNSdVIGsQXgGpVC038Ikx4EcicJeqY4=;
        b=WTX/Q3X37E23pbk9qpcffGK6lFh5IKbtjijFfpI1xduQ5fpA2XZxdbHJwdVBZchBzP
         bCmuANbMpLGhQk8hfptHNwgd82Q4tcseD0NxJUUB5Ss0pCEmbjf6D8zOhgr/qmLJlZwT
         Gk7w3sU+aR1xKCbAxg6OdBrxrR/dxtgC2z9WUtE9+ntMzdUDVpYflZx5LRkVfkhhDsZk
         Yg7jN8DVHRVP/fECEqCBRpOY0FxpURq1x4Os3mKmCvOxRHKNX6CUm6UiHhnfLNbX1yxh
         oNDw+ARhzdeAnPHP7KkxRE9K6IMdw0MPyqQJWLEzlErsK+eWglj7+5sk3pth+l34R/xu
         1XDw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YGJvCBCU;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f91sor2312479plf.59.2019.02.13.23.25.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 23:25:30 -0800 (PST)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YGJvCBCU;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=hj2BGzvLaj4ffNSdVIGsQXgGpVC038Ikx4EcicJeqY4=;
        b=YGJvCBCUl0fjU0BhKfgExnzl104zdc+e/RJK4X3+mbXThLEbX9Ia9mJhn0meFKBXxI
         kV3uvQ2MiZODnLyNUHtUqz1KjTrVfyIX4GqR4NgJolUxHtJUABsc6/HHd9VJrXgNr/k+
         VZFCgXllq8c5Tg0ULTfaVry3jfeUhCL+QACmwYs+KnE0E9CF35TWD2ibpwvSyvl4mGLH
         1txUCeHpgnMcnm/GlUXqtLJlrKl3jUhx4WpDwtiRNBPHBEga06Tgzt0qxZ0jZOjhKDkw
         7DxwZpf9eLKyRhJZ3uzMEeNCrSlEc+IBeo/Ecav+Dxd48YEoVYuB/cAXIBOsMMBBmmaY
         a1lQ==
X-Google-Smtp-Source: AHgI3Ibklin6yOIfY8/mrPBnY9l5ASCnxfjmwhml0n4T3S2Vro2vAIw5PlRYIZiYok+EFJ4ODHWMfw==
X-Received: by 2002:a17:902:48c8:: with SMTP id u8mr2652862plh.79.1550129130124;
        Wed, 13 Feb 2019 23:25:30 -0800 (PST)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id 184sm3162999pfe.106.2019.02.13.23.25.26
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 23:25:28 -0800 (PST)
Date: Thu, 14 Feb 2019 16:25:24 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: gregkh@linuxfoundation.org, linux-mm <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Hugh Dickins <hughd@google.com>, Liu Bo <bo.liu@linux.alibaba.com>,
	stable@vger.kernel.org
Subject: Re: [PATCH] mm: Fix the pgtable leak
Message-ID: <20190214072524.GB15820@google.com>
References: <20190213112900.33963-1-minchan@kernel.org>
 <20190213120330.GD4525@dhcp22.suse.cz>
 <20190213121200.GA52615@google.com>
 <20190213122458.GF4525@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213122458.GF4525@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1+60 (6df12dc1) (2018-08-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 01:24:58PM +0100, Michal Hocko wrote:
> On Wed 13-02-19 21:12:00, Minchan Kim wrote:
> > On Wed, Feb 13, 2019 at 01:03:30PM +0100, Michal Hocko wrote:
> > > On Wed 13-02-19 20:29:00, Minchan Kim wrote:
> > > > [1] was backported to v4.9 stable tree but it introduces pgtable
> > > > memory leak because with fault retrial, preallocated pagetable
> > > > could be leaked in second iteration.
> > > > To fix the problem, this patch backport [2].
> > > > 
> > > > [1] 5cf3e5ff95876, mm, memcg: fix reclaim deadlock with writeback
> > > > [2] b0b9b3df27d10, mm: stop leaking PageTables
> > > > 
> > > > Fixes: 5cf3e5ff95876 ("mm, memcg: fix reclaim deadlock with writeback")
> > > > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > > > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > > Cc: Michal Hocko <mhocko@suse.com>
> > > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > > Cc: Hugh Dickins <hughd@google.com>
> > > > Cc: Liu Bo <bo.liu@linux.alibaba.com>
> > > > Cc: <stable@vger.kernel.org> [4.9]
> > > > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > > 
> > > Thanks for catching this dependency. Do I assume it correctly that this
> > > is stable-4.9 only?
> > 
> > I have no idea how I could find it automatically that a stable patch of
> > linus tree is spread out with several stable trees(Hope Greg has an
> > answer). I just checked 4.4 longterm kernel and couldn't find it in there.
> 
> See http://lkml.kernel.org/r/20190115174036.GA24149@dhcp22.suse.cz
> 
> But my question was more about "this is a stable only thing"? It was not
> obvious from the subject so I wanted to be sure that I am not missing
> anything.

Yub, I think only 4.9 stable tree need to be fixed because Hugh's patch was
in there since v4.10. 

Thanks.

