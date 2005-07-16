Message-ID: <42D851D0.89383435@sgi.com>
Date: Fri, 15 Jul 2005 17:16:16 -0700
From: Steve Neuner <srn@sgi.com>
MIME-Version: 1.0
Subject: Re: [NUMA] Display and modify the memory policy of a process through
 /proc/<pid>/numa_policy
References: <20050715211210.GI15783@wotan.suse.de> <Pine.LNX.4.62.0507151413360.11563@schroedinger.engr.sgi.com> <20050715214700.GJ15783@wotan.suse.de> <Pine.LNX.4.62.0507151450570.11656@schroedinger.engr.sgi.com> <20050715220753.GK15783@wotan.suse.de> <Pine.LNX.4.62.0507151518580.12160@schroedinger.engr.sgi.com> <20050715223756.GL15783@wotan.suse.de> <Pine.LNX.4.62.0507151544310.12371@schroedinger.engr.sgi.com> <20050715225635.GM15783@wotan.suse.de> <Pine.LNX.4.62.0507151602390.12530@schroedinger.engr.sgi.com> <20050715234402.GN15783@wotan.suse.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Paul Jackson <pj@sgi.com>, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> That SGI batch scheduler with its incredibly long specification
> list you guys seem to want to mess up all interfaces
> for. If I can download source to it please supply an URL.

Hi,

SGI does not have or ship a batch scheduler product.  However, 
many Linux and other OS customers want and use both open source 
and 3rd-party products that provide this capability.  For example, 
check out:
   http://www.platform.com/products/HPC/
   http://www.osc.edu/hpc/software/apps/pbs.shtml
   http://www.altair.com/software/pbs_abo.htm
   http://www.clusterresources.com/products/maui/

Hope that helps.

--steve
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
