Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id D35BF6B0031
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 13:40:14 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id a1so1870533qcx.17
        for <linux-mm@kvack.org>; Fri, 09 Aug 2013 10:40:13 -0700 (PDT)
Date: Fri, 9 Aug 2013 13:40:09 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5 1/2] workqueue: add new schedule_on_cpu_mask() API
Message-ID: <20130809174009.GV20515@mtj.dyndns.org>
References: <20130809163029.GT20515@mtj.dyndns.org>
 <201308091738.r79HcBY7003695@farm-0021.internal.tilera.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201308091738.r79HcBY7003695@farm-0021.internal.tilera.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

On Wed, Aug 07, 2013 at 04:49:44PM -0400, Chris Metcalf wrote:
> This primitive allows scheduling work to run on a particular set of
> cpus described by a "struct cpumask".  This can be useful, for example,
> if you have a per-cpu variable that requires code execution only if the
> per-cpu variable has a certain value (for example, is a non-empty list).
> 
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>

 Acked-by: Tejun Heo <tj@kernel.org>

Please feel free to route with the second patch.

Thanks!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
