Date: Fri, 02 Sep 2005 11:40:12 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: RE: [PATCH 1/1] Implement shared page tables
Message-ID: <3251CEDFF07A229DBFB81CE0@[10.1.1.4]>
In-Reply-To: <200509020158.j821wtg00465@unix-os.sc.intel.com>
References: <200509020158.j821wtg00465@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--On Thursday, September 01, 2005 18:58:23 -0700 "Chen, Kenneth W"
<kenneth.w.chen@intel.com> wrote:

>> +		prio_tree_iter_init(&iter, &mapping->i_mmap,
>> +				    vma->vm_start, vma->vm_end);
> 
> 
> I think this is a bug.  The radix priority tree for address_space->
> i_mmap is keyed on vma->vm_pgoff.  Your patch uses the vma virtual
> address to find a shareable range, Which will always fail a match
> even though there is one.
>
> Do you really have to iterate through all the vma?  Can't you just break
> out of the while loop on first successful match and populating the pmd?
> I would think you will find them to be the same pte page. Or did I miss
> some thing?

Man, I spaced that whole search code.  I was sure I'd tested to make sure
it was finding matches.  I'll fix all that up in my next release.

Dave McCracken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
