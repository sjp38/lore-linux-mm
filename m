Date: Thu, 02 Dec 2004 10:42:05 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH] Neaten page virtual choice
Message-ID: <202190000.1102012924@[10.10.2.4]>
In-Reply-To: <20041202183506.GA32283@infradead.org>
References: <20041202162621.GM5752@parcelfarce.linux.theplanet.co.uk> <20041202183506.GA32283@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Matthew Wilcox <matthew@wil.cx>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@zip.com.au>
List-ID: <linux-mm.kvack.org>

--Christoph Hellwig <hch@infradead.org> wrote (on Thursday, December 02, 2004 18:35:06 +0000):

>>  # if defined(WANT_PAGE_VIRTUAL)
>> -#define page_address(page) ((page)->virtual)
>> -#define set_page_address(page, address)			\
>> +  #define page_address(page) ((page)->virtual)
>> +  #define set_page_address(page, address)			\
> 
> urgg, this is a horrible non-standard indentation.
> 
> If you look at other kernel source you see either:
> 
>  - no indentation inside #ifdef at all (seems like most of the source)
>  - indentation after the leading #

To be fair, both of those seem far more horrible than the above ;-)
Though I'd agree it's not exactly standard.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
