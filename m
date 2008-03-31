Date: Sun, 30 Mar 2008 21:02:07 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH 8/8] x86_64: V2 Support for new UV apic
Message-ID: <20080331020207.GA20605@sgi.com>
References: <20080328191216.GA16455@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080328191216.GA16455@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu, tglx@linutronix.de, yhlu.kernel@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Fix double-shift of apicid in previous patch.

Signed-off-by: Jack Steiner <steiner@sgi.com>


---
The code is clearly wrong.  I booted on an 8p AMD box and
had no problems. Apparently the kernel (at least basic booting) is
not too sensitive to incorrect apicids being returned. Most
critical-to-boot code must use apicids from the ACPI tables.


 arch/x86/kernel/genapic_64.c |    2 --
 2 files changed, 2 insertions(+), 2 deletions(-)

Index: linux/arch/x86/kernel/genapic_64.c
===================================================================
--- linux.orig/arch/x86/kernel/genapic_64.c	2008-03-30 20:37:18.000000000 -0500
+++ linux/arch/x86/kernel/genapic_64.c	2008-03-30 20:48:30.000000000 -0500
@@ -98,8 +98,6 @@ unsigned int read_apic_id(void)
 	id = apic_read(APIC_ID);
 	if (uv_system_type >= UV_X2APIC)
 		id  |= __get_cpu_var(x2apic_extra_bits);
-	else
-		id = (id >> 24) & 0xFFu;;
 	return id;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
