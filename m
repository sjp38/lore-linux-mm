Received: by fg-out-1718.google.com with SMTP id e12so1099654fga.4
        for <linux-mm@kvack.org>; Fri, 18 Jan 2008 14:19:55 -0800 (PST)
Message-ID: <29495f1d0801181419q7ec24cc2v3843e5eba27fe207@mail.gmail.com>
Date: Fri, 18 Jan 2008 14:19:54 -0800
From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Subject: Re: crash in kmem_cache_init
In-Reply-To: <Pine.LNX.4.64.0801181414200.8924@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080115150949.GA14089@aepfle.de>
	 <84144f020801170414q7d408a74uf47a84b777c36a4a@mail.gmail.com>
	 <Pine.LNX.4.64.0801170628580.19208@schroedinger.engr.sgi.com>
	 <20080117181222.GA24411@aepfle.de>
	 <Pine.LNX.4.64.0801171049190.21058@schroedinger.engr.sgi.com>
	 <20080117211511.GA25320@aepfle.de>
	 <Pine.LNX.4.64.0801181043290.30348@schroedinger.engr.sgi.com>
	 <20080118213011.GC10491@csn.ul.ie>
	 <Pine.LNX.4.64.0801181414200.8924@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Olaf Hering <olaf@aepfle.de>, Mel Gorman <mel@csn.ul.ie>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, hanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lee.schermerhorn@hp.com, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 1/18/08, Christoph Lameter <clameter@sgi.com> wrote:
> Could you try this patch?
>
> Memoryless nodes: Set N_NORMAL_MEMORY for a node if we do not support
> HIGHMEM
>
> It seems that we only scan through zones to set N_NORMAL_MEMORY only if
> CONFIG_HIGHMEM and CONFIG_NUMA are set. We need to set
> N_NORMAL_MEMORY
> in the !CONFIG_HIGHMEM case.

I'm testing this exact patch right now on the machine Mel saw the issues with.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
