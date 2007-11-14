Message-ID: <473B423B.6030400@sgi.com>
Date: Wed, 14 Nov 2007 10:45:15 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] x86: convert-cpuinfo_x86-array-to-a-per_cpu-array
 fix
References: <20071012225433.928899000@sgi.com> <20071012225434.102879000@sgi.com>
In-Reply-To: <20071012225434.102879000@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Suresh B Siddha <suresh.b.siddha@intel.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

It appears that this patch is missing from the latest 2.6.24 git kernel?

(Suresh noticed that it is still a problem.)

Thanks,
Mike

This fix corrects the problem that early_identify_cpu() sets
cpu_index to '0' (needed when called by setup_arch) after
smp_store_cpu_info() had set it to the correct value.

Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/x86_64/kernel/smpboot.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux.orig/arch/x86_64/kernel/smpboot.c	2007-10-12 14:28:45.000000000 -0700
+++ linux/arch/x86_64/kernel/smpboot.c	2007-10-12 14:53:42.753508152 -0700
@@ -141,8 +141,8 @@ static void __cpuinit smp_store_cpu_info
 	struct cpuinfo_x86 *c = &cpu_data(id);
 
 	*c = boot_cpu_data;
-	c->cpu_index = id;
 	identify_cpu(c);
+	c->cpu_index = id;
 	print_cpu_info(c);
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
