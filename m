Subject: RE: Silly question: How to map a user space page in kernel space?
From: Robert Love <rml@tech9.net>
In-Reply-To: <7550000.1046232898@[10.10.2.4]>
References: <A46BBDB345A7D5118EC90002A5072C780A7D57BB@orsmsx116.jf.intel.com >
	 <7550000.1046232898@[10.10.2.4]>
Content-Type: text/plain
Message-Id: <1046234347.1346.132.camel@phantasy>
Mime-Version: 1.0
Date: 25 Feb 2003 23:39:08 -0500
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: "Perez-Gonzalez, Inaky" <inaky.perez-gonzalez@intel.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2003-02-25 at 23:14, Martin J. Bligh wrote:

> Each type is for a different usage, and you need to ensure that two things
> can't reuse the same type at once. As long as interrupts, or whatever could
> disturb you can't use what you use, you're OK. Note that you can't hold
> kmap_atomic over a schedule (presumably this means no pre-emption either).

Indeed, kmap_atomic() disables kernel preemption :)

Which found at least one instance of actually calling schedule() over
kmap_atomic(), due to the atomicity debugging.

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
