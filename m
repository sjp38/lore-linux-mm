Message-ID: <437BC2D7.3080003@emc.com>
Date: Wed, 16 Nov 2005 18:37:59 -0500
From: Ric Wheeler <ric@emc.com>
MIME-Version: 1.0
Subject: Re: [RFC] sys_punchhole()
References: <1131664994.25354.36.camel@localhost.localdomain>	 <20051110153254.5dde61c5.akpm@osdl.org>	 <20051113150906.GA2193@spitz.ucw.cz> <1132178470.24066.85.camel@localhost.localdomain>
In-Reply-To: <1132178470.24066.85.camel@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Pavel Machek <pavel@suse.cz>, Andrew Morton <akpm@osdl.org>, andrea@suse.de, hugh@veritas.com, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Badari Pulavarty wrote:

>On Sun, 2005-11-13 at 15:09 +0000, Pavel Machek wrote:
>  
>
>>Hi!
>>
>>    
>>
>>>>We discussed this in madvise(REMOVE) thread - to add support 
>>>>for sys_punchhole(fd, offset, len) to complete the functionality
>>>>(in the future).
>>>>
>>>>http://marc.theaimsgroup.com/?l=linux-mm&m=113036713810002&w=2
>>>>
>>>>What I am wondering is, should I invest time now to do it ?
>>>>        
>>>>
>>>I haven't even heard anyone mention a need for this in the past 1-2 years.
>>>      
>>>
>>Some database people wanted it maybe month ago. It was replaced by some 
>>madvise hack...
>>    
>>
>
>Hmm. Someone other than me asking for it ? 
>
>I did the madvise() hack and asking to see if any one really needs
>sys_punchole().
>
>Thanks,
>Badari
>
>
>  
>
I think that sys_punchole() would be useful for some object based 
storage systems.

Specifically, when you have a box that is trying to store potentially a 
billion objects on one file system, pushing several objects into a file 
("container") can be useful to keep the object count down.  The punch 
hole would be useful in reclaiming space in this type of scheme.

On the other side of the argument, you can argue that file systems that 
support large file counts and really big directories should perform well 
enough to make this use case less important.

ric


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
