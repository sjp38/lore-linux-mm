Date: Tue, 28 Mar 2000 14:26:56 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: your mail
Message-ID: <20000328142656.B16752@redhat.com>
References: <CA2568B0.002E6B38.00@d73mta05.au.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA2568B0.002E6B38.00@d73mta05.au.ibm.com>; from pnilesh@in.ibm.com on Tue, Mar 28, 2000 at 01:49:04PM +0530
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pnilesh@in.ibm.com
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Mar 28, 2000 at 01:49:04PM +0530, pnilesh@in.ibm.com wrote:
> 
> No, if both processes have faulted in the page into their ptes, it will
> be 2.

3.  The page cache counts as a reference.

> One more thing if the process ocurrs a page fault on text page it calls
> file_no_page()
> From what you said in this case it should increment the page count but in
> this function no where I could see the page count getting incremented.

It is done implicitly when filemap_nopage() looks for the page in the
page cache: __find_page() increments the reference count of any page
it finds before returning.

> The David Rusling book says when reducing page cache and buffer cache the
> page table entries are not modified and the pages can be dropped directly.

Yes, but it checks the page reference count to make sure it is legal to
do so first.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
