Message-ID: <4193BD07.5010100@tteng.com.br>
Date: Thu, 11 Nov 2004 17:27:03 -0200
From: "Luciano A. Stertz" <luciano@tteng.com.br>
MIME-Version: 1.0
Subject: Re: [Fwd: Page allocator doubt]
References: <41937940.9070001@tteng.com.br> <1100200247.932.1145.camel@localhost>
In-Reply-To: <1100200247.932.1145.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Thu, 2004-11-11 at 06:37, Luciano A. Stertz wrote:
> 
>>Only the first page got it page counter incremented. Is this expected?
> 
> 
> Yes.
	But... are they allocated to me, even with page_count zeroed? Do I need 
to do get_page on the them? Sorry if it's a too lame question, but I 
still didn't understand and found no place to read about this.

	Luciano Stertz
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
