From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199911031809.KAA88220@google.engr.sgi.com>
Subject: Re: The 4GB memory thing
Date: Wed, 3 Nov 1999 10:09:37 -0800 (PST)
In-Reply-To: <99Nov3.094606gmt.66315@gateway.ukaea.org.uk> from "Neil Conway" at Nov 3, 99 09:48:11 am
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Conway <nconway.list@ukaea.org.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> This is a multi-part message in MIME format.
> --------------8C597550CEC840E9F68E4220
> Content-Type: text/plain; charset=us-ascii
> Content-Transfer-Encoding: 7bit
> 
> The recent thread about >4GB surprised me, as I didn't even think >2GB
> was very stable yet.  Am I wrong?  Are people out there using 4GB boxes
> with decent stability?  I presume it's a 2.3 feature, yes?
> 
> Sorry for my ignorance, I guess I've been dozing a bit of late.
> 
> Neil

I have a 2.2 patch for 4Gb support, which has seen a lot of stress
testing by now. The 2.3 >2gb support uses a different (and better
approach), but last I checked, things like rawio did not work above
>2Gb. The 64Gb support is completely new ...

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
