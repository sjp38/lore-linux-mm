From: David Rientjes via Linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
Subject: (unknown)
Date: Fri, 29 Jan 2016 10:04:51 +1100 (AEDT)
Message-ID: <mailman.854.1454022227.12304.linuxppc-dev@lists.ozlabs.org>
References: <1453889401-43496-1-git-send-email-borntraeger@de.ibm.com>
 <1453889401-43496-3-git-send-email-borntraeger@de.ibm.com>
 <alpine.DEB.2.10.1601271414180.23510@chino.kir.corp.google.com>
 <56A9E3D1.3090001@de.ibm.com>
Reply-To: David Rientjes <rientjes@google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2523846124842727992=="
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <56A9E3D1.3090001@de.ibm.com>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, davej@codemonkey.org.uk, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net
List-Id: linux-mm.kvack.org

--===============2523846124842727992==
Content-Type: message/rfc822
Content-Disposition: inline

Return-Path: <rientjes@google.com>
X-Original-To: linuxppc-dev@lists.ozlabs.org
Delivered-To: linuxppc-dev@lists.ozlabs.org
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com [IPv6:2607:f8b0:400e:c03::22d])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by lists.ozlabs.org (Postfix) with ESMTPS id 5F84D1A0E27
	for <linuxppc-dev@lists.ozlabs.org>; Fri, 29 Jan 2016 10:03:42 +1100 (AEDT)
Authentication-Results: lists.ozlabs.org;
	dkim=pass (2048-bit key; unprotected) header.d=google.com header.i=@google.com header.b=CFK4cZqw;
	dkim-atps=neutral
Received: by mail-pa0-x22d.google.com with SMTP id ho8so30275670pac.2
        for <linuxppc-dev@lists.ozlabs.org>; Thu, 28 Jan 2016 15:03:42 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20120113;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version:content-type;
        bh=KrI/ntewNu+QmHN1nlVLv+cO9NO52BuLmYKAX5ZJuRw=;
        b=CFK4cZqwuyVLNJbSentvp+mBo3cSDEYGKu3CN555LWT4/Djv5F13sJ8UJ8Twi5tdVh
         KjRHkjdRcEbOKLJPCNdrvuJw2X/HV5Ww8EsN/X0OO6J8smpDu1sMf/pAfPcZ43U3ZcLF
         Y/UnKUKmZTThRGJvfT43uuPBOIfUiszPKKigFM7+Js38Gp7kBLKzwxPk27o5DKL6H4GS
         MsrCW75rQY08R6RUaU9Gg7WoK3In/rbvo3gbYJIf6JwsD2CzMbGOgwX4iozIvPTaYiop
         +qrRqqiPmNuerlRziNH78vnhUP7sUNdIKiQOHzqhiOffQ+yGG31sA3Rb8Ysck1GhVRnB
         Kt2w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20130820;
        h=x-gm-message-state:date:from:to:cc:subject:in-reply-to:message-id
         :references:user-agent:mime-version:content-type;
        bh=KrI/ntewNu+QmHN1nlVLv+cO9NO52BuLmYKAX5ZJuRw=;
        b=irQMKBXh2MW1P+VwwT4AbdsU8lQFf3+hsvJhKZVKAVjRSzDmw00NBM11Fmg6hkdvkK
         mKxMWXx3s9d9TP32nZ2XU4D/svbt8iFUv4TU+nLd6UMj+1o/rYj6G9+3paZYOnPEGAUh
         JdqJasW3IfHQEzeJB/q1pdo9ytKZJPTJK0TM1Yg09eo9QWd1cG6YafJogAeC6eJhbK/9
         kGqmiqMkfvLqL3L7NVEhUaUZYYprxVMMg0y2vGD/R6+R2Hj63Ey7ySCKg5qgkfIzE/Xj
         Ulq6RoUXhRwF38TYpwljKUO/8NqXwv/o4K/Y1BtgKSR7pWcig/LHqxHlrmMTn21A+2Wh
         WErA==
X-Gm-Message-State: AG10YOTHDGZAwcNa7yDPe+yMZG82TghIUWKphpo0pXZWtb6v/rQyMpBjl2AKsVwRfka5Fh9b
X-Received: by 10.66.229.104 with SMTP id sp8mr8440890pac.53.1454022220954;
        Thu, 28 Jan 2016 15:03:40 -0800 (PST)
Received: from [2620:0:1008:1200:6487:bec0:a70c:1362] ([2620:0:1008:1200:6487:bec0:a70c:1362])
        by smtp.gmail.com with ESMTPSA id z15sm18809219pfa.71.2016.01.28.15.03.40
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 28 Jan 2016 15:03:40 -0800 (PST)
Date: Thu, 28 Jan 2016 15:03:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Christian Borntraeger <borntraeger@de.ibm.com>
cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
    linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org,
    x86@kernel.org, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net,
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, davej@codemonkey.org.uk
Subject: Re: [PATCH v3 2/3] x86: query dynamic DEBUG_PAGEALLOC setting
In-Reply-To: <56A9E3D1.3090001@de.ibm.com>
Message-ID: <alpine.DEB.2.10.1601281500160.31035@chino.kir.corp.google.com>
References: <1453889401-43496-1-git-send-email-borntraeger@de.ibm.com> <1453889401-43496-3-git-send-email-borntraeger@de.ibm.com> <alpine.DEB.2.10.1601271414180.23510@chino.kir.corp.google.com> <56A9E3D1.3090001@de.ibm.com>
User-Agent: Alpine 2.10 (DEB 1266 2009-07-14)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII

On Thu, 28 Jan 2016, Christian Borntraeger wrote:

> Indeed, I only touched the identity mapping and dump stack.
> The question is do we really want to change free_init_pages as well?
> The unmapping during runtime causes significant overhead, but the
> unmapping after init imposes almost no runtime overhead. Of course,
> things get fishy now as what is enabled and what not.
> 
> Kconfig after my patch "mm/debug_pagealloc: Ask users for default setting of debug_pagealloc"
> (in mm) now states
> ----snip----
> By default this option will have a small overhead, e.g. by not
> allowing the kernel mapping to be backed by large pages on some
> architectures. Even bigger overhead comes when the debugging is
> enabled by DEBUG_PAGEALLOC_ENABLE_DEFAULT or the debug_pagealloc
> command line parameter.
> ----snip----
> 
> So I am tempted to NOT change free_init_pages, but the x86 maintainers
> can certainly decide differently. Ingo, Thomas, H. Peter, please advise.
> 

I'm sorry, but I thought the discussion of the previous version of the 
patchset led to deciding that all CONFIG_DEBUG_PAGEALLOC behavior would be 
controlled by being enabled on the commandline and checked with 
debug_pagealloc_enabled().

I don't think we should have a CONFIG_DEBUG_PAGEALLOC that does some stuff 
and then a commandline parameter or CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT 
to enable more stuff.  It should either be all enabled by the commandline 
(or config option) or split into a separate entity.  
CONFIG_DEBUG_PAGEALLOC_LIGHT and CONFIG_DEBUG_PAGEALLOC would be fine, but 
the current state is very confusing about what is being done and what 
isn't.

It also wouldn't hurt to enumerate what is enabled and what isn't enabled 
in the Kconfig entry.

--===============2523846124842727992==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: inline

X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KTGludXhwcGMt
ZGV2IG1haWxpbmcgbGlzdApMaW51eHBwYy1kZXZAbGlzdHMub3psYWJzLm9yZwpodHRwczovL2xp
c3RzLm96bGFicy5vcmcvbGlzdGluZm8vbGludXhwcGMtZGV2

--===============2523846124842727992==--
