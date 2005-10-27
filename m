Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: [ PATCH ] - Avoid slow TLB purges on SGI Altix systems
Date: Thu, 27 Oct 2005 09:01:53 -0700
Message-ID: <B8E391BBE9FE384DAA4C5C003888BE6F04C8CF40@scsmsx401.amr.corp.intel.com>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dean Roe <roe@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-	if (mm != current->active_mm) {
-		/* this does happen, but perhaps it's not worth optimizing for? */
-#ifdef CONFIG_SMP
-		flush_tlb_all();
-#else
-		mm->context = 0;
-#endif
-		return;
-	}

Your patch moves this secion of code up to ia64_global_tlb_purge(),
but the new code that is added there doesn't include the UP case
where mm->context is set to zero.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
