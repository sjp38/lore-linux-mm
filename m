Date: Wed, 2 Apr 2003 15:52:20 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH 2.5.66-mm2] Fix page_convert_anon locking issues
Message-Id: <20030402155220.651a1005.akpm@digeo.com>
In-Reply-To: <110950000.1049326945@baldur.austin.ibm.com>
References: <8910000.1049303582@baldur.austin.ibm.com>
	<20030402132939.647c74a6.akpm@digeo.com>
	<80300000.1049320593@baldur.austin.ibm.com>
	<20030402150903.21765844.akpm@digeo.com>
	<102170000.1049325787@baldur.austin.ibm.com>
	<20030402153845.0770ef54.akpm@digeo.com>
	<110950000.1049326945@baldur.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Dave McCracken <dmccr@us.ibm.com> wrote:
>
> 
> Oops.  The pmd_present() check should be after the page_to_pfn() !=
> pte_pfn() check.
> 

hmmmm.  It also probably needs both compiler barriers and memory barriers.

It does give me creepy feelings.  I worry that because nobody uses
remap_file_pages() yet, we will hit 2.6.25 before discovering that we have
fundamental VM locking problems which affect $major$ applications.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
