Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id D37726B0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 16:58:05 -0500 (EST)
Date: Mon, 18 Feb 2013 23:57:46 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2] net: fix functions and variables related to
 netns_ipvs->sysctl_sync_qlen_max
In-Reply-To: <5121C699.2050408@cn.fujitsu.com>
Message-ID: <alpine.LFD.2.00.1302182253560.1723@ja.ssi.bg>
References: <51131B88.6040809@cn.fujitsu.com> <51132A56.60906@cn.fujitsu.com> <alpine.LFD.2.00.1302070944480.1810@ja.ssi.bg> <20130214142159.d0516a5f.akpm@linux-foundation.org> <alpine.LFD.2.00.1302152304010.1746@ja.ssi.bg>
 <5121C699.2050408@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-176011512-1361224671=:1723"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net, Simon Horman <horms@verge.net.au>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-176011512-1361224671=:1723
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Mon, 18 Feb 2013, Zhang Yanfei wrote:

> ao? 2013a1'02ae??16ae?JPY 05:39, Julian Anastasov a??e??:
> > 
> > 	Hello,
> > 
> > On Thu, 14 Feb 2013, Andrew Morton wrote:
> > 
> >> Redarding this patch:
> >> net-change-type-of-netns_ipvs-sysctl_sync_qlen_max.patch and
> >> net-fix-functions-and-variables-related-to-netns_ipvs-sysctl_sync_qlen_max.patch
> >> are joined at the hip and should be redone as a single patch with a
> >> suitable changelog, please.  And with a cc:netdev@vger.kernel.org.
> > 
> > 	Agreed, Zhang Yanfei and Simon? I'm just not sure,
> > may be this combined patch should hit only the
> > ipvs->nf->net trees? Or may be net-next, if we don't have
> > time for 3.8.
> > 
> 
> Should I resend the combined patch?

	Yes, please! Just add CC: netdev@vger.kernel.org.
Simon will take the patch for the networking trees.

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-176011512-1361224671=:1723--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
