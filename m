Message-ID: <41E8F7F7.1010908@yahoo.com.au>
Date: Sat, 15 Jan 2005 22:01:11 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Odd kswapd behaviour after suspending in 2.6.11-rc1
References: <20050113061401.GA7404@blackham.com.au>	 <41E61479.5040704@yahoo.com.au> <20050113085626.GA5374@blackham.com.au>	 <20050113101426.GA4883@blackham.com.au>  <41E8ED89.8090306@yahoo.com.au>	 <1105785254.13918.4.camel@desktop.cunninghams>	 <41E8F313.4030102@yahoo.com.au> <1105786115.13918.9.camel@desktop.cunninghams>
In-Reply-To: <1105786115.13918.9.camel@desktop.cunninghams>
Content-Type: multipart/mixed;
 boundary="------------070303030109030502040501"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ncunningham@linuxmail.org
Cc: Bernard Blackham <bernard@blackham.com.au>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070303030109030502040501
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Nigel Cunningham wrote:
> Hi Nick.
> 
> On Sat, 2005-01-15 at 21:40, Nick Piggin wrote:
> 

>>I've seen try to do order 8 allocations or something almost as
>>ridiculous. Atomic too.
> 
> 
> I believe you. But Bernard and I are dealing with Suspend2.
> 

Sorry, indeed you are. My mistake.

> 
>>Well, correction, I've seen _reports_. Never tried swsusp myself.
> 
> 
> :>
> 
>>I don't think a few order 0 and 1 allocations would do any harm
>>because otherwise every man and his dog would be having problems.
> 
> 
> Yes. Suspend2 does allocate a large number of zero order allocations for
> submitting I/O, but again, they're all freed prior to thawing frozen
> processes.
> 

Hmm. I wouldn't have thought that should be a problem. Obviously
something is just irritating a bug somewhere.

> 
>>>>Thanks for the report... I'll come up with something for you to try
>>>>in the next day or so.
>>>
>>>
>>>I'm flying to America on Monday, but I'll try to keep up with the
>>>progress in this and do anything I can to help.
>>>
>>
>>It is basically a problem with one of my patches. I should be able
>>to fix it (although fixing swsusp would be nice too :) ).
> 
> 
> :> Nevertheless, if there's something suspend2 related I should fix...
> 

I wouldn't suspect so, but we'll see... How do I get my hands on
suspend2?

Also, Bernard, can you try running with the following patch and
see what output it gives when you reproduce the problem?

Thanks a lot,
Nick

--------------070303030109030502040501
Content-Type: text/plain;
 name="kswapd-debug"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="kswapd-debug"

SW5kZXg6IGxpbnV4LTIuNi9tbS92bXNjYW4uYwo9PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09Ci0tLSBsaW51eC0y
LjYub3JpZy9tbS92bXNjYW4uYwkyMDA1LTAxLTE1IDIxOjU0OjI0LjU3OTEzNDI5NCArMTEw
MAorKysgbGludXgtMi42L21tL3Ztc2Nhbi5jCTIwMDUtMDEtMTUgMjE6NTY6NTEuNzE5MzU1
OTI5ICsxMTAwCkBAIC0xMTgyLDYgKzExODIsNyBAQAogCQl9CiAJCWZpbmlzaF93YWl0KCZw
Z2RhdC0+a3N3YXBkX3dhaXQsICZ3YWl0KTsKIAorCQlwcmludGsoImtzd2FwZDogYmFsYW5j
ZV9wZ2RhdCwgb3JkZXIgPSAlbHVcbiIsIG9yZGVyKTsKIAkJYmFsYW5jZV9wZ2RhdChwZ2Rh
dCwgMCwgb3JkZXIpOwogCX0KIAlyZXR1cm4gMDsK
--------------070303030109030502040501--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
