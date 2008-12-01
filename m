Subject: Re: [patch][rfc] acpi: do not use kmem caches
From: Andi Kleen <andi@firstfloor.org>
References: <20081201083128.GB2529@wotan.suse.de>
	<84144f020812010318v205579ean57edecf7992ec7ef@mail.gmail.com>
	<20081201120002.GB10790@wotan.suse.de> <4933E2C3.4020400@gmail.com>
	<1228138641.14439.18.camel@penberg-laptop>
	<4933EE8A.2010007@gmail.com> <20081201161404.GE10790@wotan.suse.de>
	<4934149A.4020604@gmail.com>
	<4911F71203A09E4D9981D27F9D8308580DC5D17C@orsmsx503.amr.corp.intel.com>
Date: Mon, 01 Dec 2008 18:30:54 +0100
In-Reply-To: <4911F71203A09E4D9981D27F9D8308580DC5D17C@orsmsx503.amr.corp.intel.com> (Robert Moore's message of "Mon, 1 Dec 2008 09:20:03 -0800")
Message-ID: <878wqz6bw1.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Moore, Robert" <robert.moore@intel.com>
Cc: Alexey Starikovskiy <aystarik@gmail.com>, Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "lenb@kernel.org" <lenb@kernel.org>
List-ID: <linux-mm.kvack.org>

"Moore, Robert" <robert.moore@intel.com> writes:

> As I recall, the ACPICA local cache greatly improves performance of the iASL compiler and AcpiExec on Windows (for BIOS writers, iASL on Windows is most important).
>

Perhaps it would be a possibility to isolate the cache in a special layer
that is only compiled in for Windows?

-Andi

-- 
ak@linux.intel.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
