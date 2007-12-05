Message-ID: <4755F041.4000605@google.com>
Date: Tue, 04 Dec 2007 16:26:41 -0800
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: page_referenced() and VM_LOCKED
References: <473D1BC9.8050904@google.com> <20071116144641.f12fd610.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0711161749020.12201@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0711161749020.12201@blonde.wat.veritas.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Fri, 16 Nov 2007, KAMEZAWA Hiroyuki wrote:
>> On Thu, 15 Nov 2007 20:25:45 -0800
>> Ethan Solomita <solo@google.com> wrote:
>>
>>> page_referenced_file() checks for the vma to be VM_LOCKED|VM_MAYSHARE
>>> and adds returns 1.
> 
> That's a case where it can deduce that the page is present and should
> be treated as referenced, without even examining the page tables.
> 
>>> We don't do the same in page_referenced_anon().
> 
> It cannot make that same deduction in the page_referenced_anon() case
> (different vmas may well contain different COWs of some original page).

	Sorry to come back in with this so late -- if the vma is VM_MAYSHARE, 
would there be COWs of the original page?
	-- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
