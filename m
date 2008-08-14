Message-ID: <48A4AC39.7020707@sciatl.com>
Date: Thu, 14 Aug 2008 15:05:45 -0700
From: C Michael Sundius <Michael.sundius@sciatl.com>
MIME-Version: 1.0
Subject: sparsemem support for mips with highmem
Content-Type: multipart/mixed;
 boundary="------------010403040800010305090501"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-mips@linux-mips.org, jfraser@broadcom.com, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------010403040800010305090501
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi

I just got sparsemem working on our MIPS 32 platform. I'm not sure if 
anyone
has done that before since there seems to be a couple of problems in the 
arch specific code.

Well I realize that it is blazingly simple to turn on sparsemem, but for 
the idiots (like myself)
out there I created a howto file to put in the Documentation directory 
just because I thought
it would be a good idea to have some official info on  it written down 
somewhere.

it saved me a ton of space by the way.  it seems to work great.

Mike


--------------010403040800010305090501
Content-Type: text/plain;
 name="mypatchfile"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mypatchfile"


--------------010403040800010305090501--
