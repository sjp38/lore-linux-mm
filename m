Date: Wed, 4 Feb 2004 00:30:27 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Active Memory Defragmentation: Our implementation & problems
Message-Id: <20040204003027.375a539e.akpm@osdl.org>
In-Reply-To: <1180000.1075879076@[10.10.2.4]>
References: <20040204050915.59866.qmail@web9704.mail.yahoo.com>
	<1075874074.14153.159.camel@nighthawk>
	<35380000.1075874735@[10.10.2.4]>
	<1075875756.14153.251.camel@nighthawk>
	<38540000.1075876171@[10.10.2.4]>
	<1075876826.14166.314.camel@nighthawk>
	<1180000.1075879076@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: haveblue@us.ibm.com, rangdi@yahoo.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@aracnet.com> wrote:
>
>  As long as we make sure the process doesn't run during the move, I don't
>  see why it'd be a problem. But I am less than convinced that rmap will
>  lead us back from the PTE page to the mm, at least w/o modification.

ptep_to_mm() at your service.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
