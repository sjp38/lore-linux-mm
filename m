Received: from saturn.hrz.tu-chemnitz.de (saturn.hrz.tu-chemnitz.de [134.109.132.51])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA25165
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 18:53:01 -0500
Date: Mon, 11 Jan 1999 00:52:18 +0100 (CET)
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: I/O and MM question
In-Reply-To: <Pine.LNX.4.03.9901101752050.13236-100000@zap.zap>
Message-ID: <Pine.LNX.4.04.9901110047460.29777-100000@nightmaster.csn.tu-chemnitz.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Jelle Foks <jelle@flying.demon.nl>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 10 Jan 1999, Jelle Foks wrote:

> (how/which function to use?). Does the mm/paging system of Linux allow me
> this? Or does the mm/paging code already somehow eliminate the memory-copy
> of the fread()->fwrite() combo (how?)? 

What about sendfile(2) ? It's linux-sepcific, but it does avoid
the getuser/putuser-couple for the data to be read/written.

cu
  Ingo
-- 
Feel the power of the penguin - run linux@your.pc
<esc>:x

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
