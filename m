Date: Thu, 7 Nov 2002 03:38:42 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: get_user_pages rewrite (completed, updated for 2.4.46)
Message-ID: <20021107113842.GB23425@holomorphy.com>
References: <20021107110840.P659@nightmaster.csn.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20021107110840.P659@nightmaster.csn.tu-chemnitz.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 07, 2002 at 11:08:40AM +0100, Ingo Oeser wrote:
+#ifdef OBSOLETE_PAGE_WALKER
+	if (vmas) {
+		gup_u.pv.vmas = vmas;
+		gup_u.pv.max_vmas = len;
+		walker = gup_add_pv;
+		printk("Obsolete argument \"vmas\" used!"
+		       " Please send this report to linux-mm@vger.kernel.org"
+		       " or fix the caller. Stack trace follows...\n");
+		WARN_ON(vmas);
+	}
+#else
+	/* FIXME: Or should we simply ignore it? -ioe */
+	BUG_ON(vmas);
+#endif

What on earth? Why not just remove the obsolete code?


Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
