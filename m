Message-ID: <3BBBA05D.4070307@brsat.com.br>
Date: Wed, 03 Oct 2001 20:33:49 -0300
From: Roberto Orenstein <roberto@brsat.com.br>
Reply-To: roberto@brsat.com.br
MIME-Version: 1.0
Subject: Re: weird memshared value
References: <3BBB7F5F.9040806@brsat.com.br> <20011003143038.B7266@mikef-linux.matchmail.com> <3BBB921D.3080805@brsat.com.br> <20011003153721.E7266@mikef-linux.matchmail.com> <3BBB9F01.1080200@brsat.com.br>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, mfedyk@matchmail.com
List-ID: <linux-mm.kvack.org>

now I remebered to post to the list. guess I need to take a rest :(

 Mike Fedyk wrote:
 
> On Wed, Oct 03, 2001 at 07:33:01PM -0300, Roberto Orenstein wrote:
> 
>> Hi Mike
>> 
>> Thanx for the help. Patch applied and problem vanish :)
>> 
>> 
>> regards
>> 
>> Roberto
>> 
> 
 
> Be sure to post that to the list.  We need success reports for these 
> types
> of things.
 
     
 Ok. I just thought it was a well know thing that I missed :)
 
> I have yet to test the patch myself.
> 
> I was able to reliably reproduce it by setting my ram down to 64mb 
> with no
> swap and running mozilla with kde...
 
 
 I run that test and it didn't trigger.
 I also did the same thing that trigger it here: cp kernel_source 
 new_source and a make bzImage in another term. Everythig is normal. Just 
 fine.
 
 Roberto


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
