Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [PATCH] Optimize out pte_chain take three
Date: Sat, 13 Jul 2002 16:20:42 +0200
References: <20810000.1026311617@baldur.austin.ibm.com> <20020710222210.GU25360@holomorphy.com> <3D2CD3D3.B43E0E1F@zip.com.au>
In-Reply-To: <3D2CD3D3.B43E0E1F@zip.com.au>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17TNlL-0003JI-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>, William Lee Irwin III <wli@holomorphy.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thursday 11 July 2002 02:39, Andrew Morton wrote:
> I can do the coding, although by /bin/sh skills
> are woeful...

Careful... I've seen some recent test loads where the script time
dominated run time, and this was for filesystem operations!

Little C programs are both more readable and more accurate.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
