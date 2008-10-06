Received: from sj-core-5.cisco.com (sj-core-5.cisco.com [171.71.177.238])
	by sj-dkim-3.cisco.com (8.12.11/8.12.11) with ESMTP id m96KFnk3004507
	for <linux-mm@kvack.org>; Mon, 6 Oct 2008 13:15:49 -0700
Received: from sausatlsmtp2.sciatl.com ([192.133.217.159])
	by sj-core-5.cisco.com (8.13.8/8.13.8) with ESMTP id m96KFmRL002389
	for <linux-mm@kvack.org>; Mon, 6 Oct 2008 20:15:48 GMT
Message-ID: <48EA71F0.3060003@sciatl.com>
Date: Mon, 06 Oct 2008 13:15:44 -0700
From: C Michael Sundius <Michael.sundius@sciatl.com>
MIME-Version: 1.0
Subject: Re: Have ever checked in your mips sparsemem code into mips-linux
 tree?
References: <48A4AC39.7020707@sciatl.com> <1218753308.23641.56.camel@nimitz> <48A4C542.5000308@sciatl.com> <20080826090936.GC29207@brain>
In-Reply-To: <20080826090936.GC29207@brain>
Content-Type: multipart/mixed;
 boundary="------------040706090500010903010809"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-mips@linux-mips.org, me94043@yahoo.com, "VomLehn, David" <dvomlehn@cisco.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------040706090500010903010809
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

John wrote:


> Hi Michael,
>
> After I read this link, noticed that you have the following patch, but when I check up the mips-linux, the patch is not there.
>
> I wonder if you could explain to me a little bit?
>
> Thank you!
>
> John
> P.S.: I also worked at SciAtl a few years ago in IPTV division.
>   
John,

I *think* I got tentative signoff from Dave and Any below as per the 
copied snipits below.
I made the modifications that they suggested. please see the attached 
for two patches:
a) the code
b) the sparsemem.txt doc

not sure if the mips powers that be were ok w/ it. pardon my ignorance, 
not sure if I am
required to do anymore. There was some comment to try this out w/ the 
CONFIG_SPARSEMEM_VMEMMAP
which I believe should "just work", but we've never tried it as of yet, 
so by my rule I can't
say it is so.. (has anyone tried that?)

Mike

====================================================


Dave Hansen wrote:

Looks great to me.  I can't test it, of course, but I don't see any
problems with it.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>

-- Dave


Andy Whitcroft wrote:
>
>
> Otherwise it looks good to me.  I see from the rest of the thread that
> there is some discussion over the sizes of these, with that sorted.
>
> Acked-by: Andy Whitcroft <apw@shadowen.org>
>
> -apw
>   
adding patch 1 containing code only:





     - - - - -                              Cisco                            - - - - -         
This e-mail and any attachments may contain information which is confidential, 
proprietary, privileged or otherwise protected by law. The information is solely 
intended for the named addressee (or a person responsible for delivering it to 
the addressee). If you are not the intended recipient of this message, you are 
not authorized to read, print, retain, copy or disseminate this message or any 
part of it. If you have received this e-mail in error, please notify the sender 
immediately by return e-mail and delete it from your computer.
--------------040706090500010903010809
Content-Type: text/x-patch;
 name="0001-mips-sparsemem-support.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="0001-mips-sparsemem-support.patch"


--------------040706090500010903010809--
