Date: Wed, 26 Feb 2003 12:40:22 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: RE: Silly question: How to map a user space page in kernel space?
In-Reply-To: <A46BBDB345A7D5118EC90002A5072C780A7D57E6@orsmsx116.jf.intel.com>
Message-ID: <Pine.LNX.4.44.0302261233010.16378-100000@skynet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Perez-Gonzalez, Inaky" <inaky.perez-gonzalez@intel.com>
Cc: "'Martin J. Bligh'" <mbligh@aracnet.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 25 Feb 2003, Perez-Gonzalez, Inaky wrote:

> I think I still don't really understand what's up with the KM_ flags :]
>

I'm doing a bit of VM documentation work. I haven't released an update in
a while but I have a chapter on high memory management chapter in my
working version. It covers the various kmap functions, atomic mapping and
an explanation of KM_ flags. I uploaded just that chapter to
http://www.csn.ul.ie/~mel/projects/vm/tmp/ in both PDF (recommended one to
view) and plain text format if you want to take a look. It's against
2.4.20, but I believe it is of relevance to 2.5.x as well

Hope that helps

-- 
Mel Gorman
MSc Student, University of Limerick
http://www.csn.ul.ie/~mel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
