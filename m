Subject: Re: [ckrm-tech] [PATCH 3/3][RFC] Containers: Pagecache controller
	reclaim
From: Shane <ibm-main@tpg.com.au>
In-Reply-To: <45ED4CF7.7030501@linux.vnet.ibm.com>
References: <20070305145237.003560000@linux.vnet.ibm.com> >
	 <20070305145311.247699000@linux.vnet.ibm.com> >
	 <1173178212.4998.54.camel@localhost.localdomain>
	 <45ED4CF7.7030501@linux.vnet.ibm.com>
Content-Type: text/plain
Date: Wed, 07 Mar 2007 19:03:59 +1000
Message-Id: <1173258239.4998.79.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Cc: riel@redhat.com, vatsa@in.ibm.com, ckrm-tech@lists.sourceforge.net, balbir@in.ibm.com, linux-kernel@vger.kernel.org, xemul@sw.ru, linux-mm@kvack.org, menage@google.com, devel@openvz.org, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, 2007-03-06 at 16:43 +0530, Vaidyanathan Srinivasan wrote:
> 
> Please let me know if so see any problem running the patch.  The
> patches are against 2.6.20 only since dependent patches are at that level.

My problem - a bad copy of the patch. It patches o.k.
However, it fails to compile vmscan. This looks a bit dodgy;

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

@@ -1470,11 +1494,13 @@ unsigned long shrink_all_memory(unsigned
        int pass;
        struct reclaim_state reclaim_state;
        struct scan_control sc = {
-               .gfp_mask = GFP_KERNEL,
+               .gfp_mask = GFdefined(CONFIG_CONTAINER_PAGECACHE_ACCT)
+P_KERNEL,

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

I deleted what looks like an over-enthusiastic "copy-and-paste", and it
compiled o.k.
Testing continues.

Shane ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
