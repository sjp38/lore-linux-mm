Reply-To: Gerrit Huizenga <gh@us.ibm.com>
From: Gerrit Huizenga <gh@us.ibm.com>
Subject: Re: statm_pgd_range() sucks! 
In-reply-to: Your message of Thu, 29 Aug 2002 20:12:08 PDT.
             <20020830031208.GK888@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <21766.1030729534.1@us.ibm.com>
Date: Fri, 30 Aug 2002 10:45:35 -0700
Message-Id: <E17kppv-0005f8-00@w-gerrit2>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@zip.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@surriel.com
List-ID: <linux-mm.kvack.org>

In message <20020830031208.GK888@holomorphy.com>, > : William Lee Irwin III wri
tes:
> I'm basically looking for VSZ, RSS, %cpu, & pid -- after that I don't
> care. top(1) examines a lot more than it feeds into the display, for
> reasons unknown. In principle, there are ways of recovering the other
> bits that seem too complex to be worthy of doing:

Try using "f" inside of top(1).  You'll see a set of additional
bits of info that it can report which may map to the data that it
examines but you haven't seen in its display.

gerrit
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
