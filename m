Message-ID: <4325D55E.1000707@kolumbus.fi>
Date: Mon, 12 Sep 2005 22:22:06 +0300
From: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/2] i386: consolidate discontig functions into	normal
 ones
References: <20050912175319.7C51CF96@kernel.beaverton.ibm.com>	 <4325D150.6040505@kolumbus.fi> <1126552121.5892.28.camel@localhost>
In-Reply-To: <1126552121.5892.28.camel@localhost>
Content-Transfer-Encoding: 8BIT
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:

>On Mon, 2005-09-12 at 22:04 +0300, Mika Penttila wrote:
>  
>
>>I think you allocate remap pages for nothing in the flatmem case for 
>>node0...those aren't used for the mem map in !NUMA.
>>    
>>
>
>I believe that is fixed up in the second patch.  It should compile a
>do{}while(0) version instead of doing a real call.  
>
>-- Dave
>
>
>  
>
Oh, yes, indeend it is.
Thanks,
Mika


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
