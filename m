From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199911022310.PAA73648@google.engr.sgi.com>
Subject: Re: >4GB memory support.. ?
Date: Tue, 2 Nov 1999 15:10:29 -0800 (PST)
In-Reply-To: <199911021653859.SM00207@mailhost.directlink.net> from "Javan Dempsey" at Nov 2, 99 04:53:21 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: raz@mailhost.directlink.net
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> Anyone have any plans of tackling >4GB support? We just rolled some machines into production with 4GB recently, and are looking at needing support for more mem if remotely possible soon. Our machines will currently take upto 6GB. Kanoj? =)
>

Ingo Molnar from RedHat has put in the 64Gb support code into 2.3.
You can turn on this support during make config by 
Processor type and features -> High Memory Support.  

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
