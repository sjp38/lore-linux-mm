Message-ID: <418123DA.1090609@us.ibm.com>
Date: Thu, 28 Oct 2004 09:52:42 -0700
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] Re: [RFC] sparsemem patches (was nonlinear)
References: <098973549.shadowen.org> <418118A1.9060004@us.ibm.com> <41811F3A.1090706@shadowen.org>
In-Reply-To: <41811F3A.1090706@shadowen.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: lhms-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andy Whitcroft wrote:
> Dave Hansen wrote:
>> Have you given any thought to using virt_to_page(page)->foo method to 
>> store section information instead of using page->flags?  It seems 
>> we're already sucking up page->flags left and right, and I'd hate to 
>> consume that many more.
> 
> As Martin indicates we don't use any more flags on the bit challenged 
> arches where this would be an issue. 

Could you explain a little bit how the section is encoded in there, and 
what kind of limits there are?  How many free bits do you need, and are 
there implications when it grows or shrinks as new PG_flags are added?

> The little trick you used has some 
> overhead to it, and current testing is showing an unexpected performance 
> improvement with this stack.

Does my little trick just have an anticipated performance impact, or a 
measured one?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
