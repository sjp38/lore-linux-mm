Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id D0BA66B013E
	for <linux-mm@kvack.org>; Sat, 18 Feb 2012 04:03:04 -0500 (EST)
Received: by lamf4 with SMTP id f4so6145184lam.14
        for <linux-mm@kvack.org>; Sat, 18 Feb 2012 01:03:02 -0800 (PST)
Date: Sat, 18 Feb 2012 11:02:55 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [rfc PATCH]slub: per cpu partial statistics change
In-Reply-To: <1329462406.12669.2919.camel@debian>
Message-ID: <alpine.LFD.2.02.1202181102110.2447@tux.localdomain>
References: <1328256695.12669.24.camel@debian>  <alpine.DEB.2.00.1202030920060.2420@router.home>  <4F2C824E.8080501@intel.com>  <alpine.DEB.2.00.1202060858510.393@router.home>  <1328591165.12669.168.camel@debian>  <alpine.DEB.2.00.1202070910320.29500@router.home>
  <1328676290.12669.431.camel@debian>  <alpine.DEB.2.00.1202080846030.29839@router.home> <1329462406.12669.2919.camel@debian>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Alex,Shi" <alex.shi@intel.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>

On Fri, 17 Feb 2012, Alex,Shi wrote:
> Pakka:
> Would you like to pick up this patch? It works on latest Linus' tree.

Applied, thanks! Can you please use my @kernel.org email address in the 
future? I don't really follow this account as often.

 			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
