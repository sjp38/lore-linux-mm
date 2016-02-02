From: David Rientjes via Linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
Subject: (unknown)
Date: Wed,  3 Feb 2016 08:52:46 +1100 (AEDT)
Message-ID: <mailman.1145.1454449904.12304.linuxppc-dev@lists.ozlabs.org>
References: <1453889401-43496-1-git-send-email-borntraeger@de.ibm.com>
 <1453889401-43496-3-git-send-email-borntraeger@de.ibm.com>
 <alpine.DEB.2.10.1601271414180.23510@chino.kir.corp.google.com>
 <56A9E3D1.3090001@de.ibm.com>
 <alpine.DEB.2.10.1601281500160.31035@chino.kir.corp.google.com>
Reply-To: David Rientjes <rientjes@google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7384601280624994056=="
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <alpine.DEB.2.10.1601281500160.31035@chino.kir.corp.google.com>
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

--===============7384601280624994056==
Content-Type: message/rfc822
Content-Disposition: inline

Return-Path: <rientjes@google.com>
X-Original-To: linuxppc-dev@lists.ozlabs.org
Delivered-To: linuxppc-dev@lists.ozlabs.org
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com [IPv6:2607:f8b0:400e:c00::236])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by lists.ozlabs.org (Postfix) with ESMTPS id D87CF1A0204
	for <linuxppc-dev@lists.ozlabs.org>; Wed,  3 Feb 2016 08:51:39 +1100 (AEDT)
Authentication-Results: lists.ozlabs.org;
	dkim=pass (2048-bit key; unprotected) header.d=google.com header.i=@google.com header.b=aD1uBLau;
	dkim-atps=neutral
Received: by mail-pf0-x236.google.com with SMTP id w123so1092865pfb.0
        for <linuxppc-dev@lists.ozlabs.org>; Tue, 02 Feb 2016 13:51:39 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20120113;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version:content-type;
        bh=TMWMuLKyzFjVKjQSgHVUsYZgrlplQT3uS4flE+ygaPc=;
        b=aD1uBLauawXUiBi2he0qc8KnyGTs8u4u37Cu6F6Rl5Oq10qCWGr0kyfOJKQB1a8VAe
         eKOPPnwDuFe7JDN0OCz07oqQaMGR1sN6SDTBFEgUymC17vV+oMOmUdS31JJ2qMi/KNfU
         4K7EmK3GwWWw91yx1QnUAPK9TcswDYuTc33Lm1ejLxvToMzi5vkUT0YqEkR/95yUNcbc
         DbyxDhaxB0Gtcq1LCKFhI19zzIOnfuN/vXPdvF4QvdNAJfRLNqrvcQIvEdeEbtDXv/Hz
         X6i2tuCQ5IJQOh2dTXwA0i82981c5wYxyRFYq1ravuxIBZB5VwHck/0BLlvNzqbJKcIR
         kNbw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20130820;
        h=x-gm-message-state:date:from:to:cc:subject:in-reply-to:message-id
         :references:user-agent:mime-version:content-type;
        bh=TMWMuLKyzFjVKjQSgHVUsYZgrlplQT3uS4flE+ygaPc=;
        b=VmI7Ms17YN631rQJ5xmb0HRl9qvk7mV8nsm9MyWKjp8lfuNmdfMcGURE0lNUMWXH8S
         m6p29NKZ8Bmdxw+Zplm0poU6GrrC0QHToHLxZJB5MMv5wVwMumQ4bt4BVFITLEJhGR54
         yI+8t0tJHRLTW/70/X7wiwPtNgsqIm1Y45Nmj0HX9yMxc6h6ZOvkx7lcaaeUVzJc3Qw4
         NGwcQgDCG7sThiSuYurTMhjPTFcCRvrLOFyGB7tOd0FuHgMNJBKAxNjHWj/8AknjEvA6
         vgtxaf172PvBTuX3nmURVTV6/XptTLTbwws/g64gfuiGti8d3+9ewHUhvTaA0dCohcUE
         3bVQ==
X-Gm-Message-State: AG10YOQHWLxlPp5DPEiVbdnaTfG5Aa+oF126n7ucspKBGGyINH75fafLDDKT2islq/MM6ls7
X-Received: by 10.98.8.14 with SMTP id c14mr50487655pfd.42.1454449896347;
        Tue, 02 Feb 2016 13:51:36 -0800 (PST)
Received: from [2620:0:1008:1200:845f:fa21:c55:89c2] ([2620:0:1008:1200:845f:fa21:c55:89c2])
        by smtp.gmail.com with ESMTPSA id 72sm4853028pfk.28.2016.02.02.13.51.35
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 02 Feb 2016 13:51:35 -0800 (PST)
Date: Tue, 2 Feb 2016 13:51:34 -0800 (PST)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Christian Borntraeger <borntraeger@de.ibm.com>
cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
    linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org,
    x86@kernel.org, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net,
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, davej@codemonkey.org.uk
Subject: Re: [PATCH v3 2/3] x86: query dynamic DEBUG_PAGEALLOC setting
In-Reply-To: <alpine.DEB.2.10.1601281500160.31035@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1602021351290.4977@chino.kir.corp.google.com>
References: <1453889401-43496-1-git-send-email-borntraeger@de.ibm.com> <1453889401-43496-3-git-send-email-borntraeger@de.ibm.com> <alpine.DEB.2.10.1601271414180.23510@chino.kir.corp.google.com> <56A9E3D1.3090001@de.ibm.com>
 <alpine.DEB.2.10.1601281500160.31035@chino.kir.corp.google.com>
User-Agent: Alpine 2.10 (DEB 1266 2009-07-14)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII

On Thu, 28 Jan 2016, David Rientjes wrote:

> On Thu, 28 Jan 2016, Christian Borntraeger wrote:
> 
> > Indeed, I only touched the identity mapping and dump stack.
> > The question is do we really want to change free_init_pages as well?
> > The unmapping during runtime causes significant overhead, but the
> > unmapping after init imposes almost no runtime overhead. Of course,
> > things get fishy now as what is enabled and what not.
> > 
> > Kconfig after my patch "mm/debug_pagealloc: Ask users for default setting of debug_pagealloc"
> > (in mm) now states
> > ----snip----
> > By default this option will have a small overhead, e.g. by not
> > allowing the kernel mapping to be backed by large pages on some
> > architectures. Even bigger overhead comes when the debugging is
> > enabled by DEBUG_PAGEALLOC_ENABLE_DEFAULT or the debug_pagealloc
> > command line parameter.
> > ----snip----
> > 
> > So I am tempted to NOT change free_init_pages, but the x86 maintainers
> > can certainly decide differently. Ingo, Thomas, H. Peter, please advise.
> > 
> 
> I'm sorry, but I thought the discussion of the previous version of the 
> patchset led to deciding that all CONFIG_DEBUG_PAGEALLOC behavior would be 
> controlled by being enabled on the commandline and checked with 
> debug_pagealloc_enabled().
> 
> I don't think we should have a CONFIG_DEBUG_PAGEALLOC that does some stuff 
> and then a commandline parameter or CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT 
> to enable more stuff.  It should either be all enabled by the commandline 
> (or config option) or split into a separate entity.  
> CONFIG_DEBUG_PAGEALLOC_LIGHT and CONFIG_DEBUG_PAGEALLOC would be fine, but 
> the current state is very confusing about what is being done and what 
> isn't.
> 

Ping?

--===============7384601280624994056==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: inline

X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KTGludXhwcGMt
ZGV2IG1haWxpbmcgbGlzdApMaW51eHBwYy1kZXZAbGlzdHMub3psYWJzLm9yZwpodHRwczovL2xp
c3RzLm96bGFicy5vcmcvbGlzdGluZm8vbGludXhwcGMtZGV2

--===============7384601280624994056==--
