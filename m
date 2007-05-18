From: Andi Kleen <ak@suse.de>
Subject: Re: signals logged / [RFC] log out-of-virtual-memory events
Date: Fri, 18 May 2007 13:47:13 +0200
References: <464C81B5.8070101@users.sourceforge.net> <464C9D82.60105@redhat.com> <Pine.LNX.4.61.0705180825280.3231@yvahk01.tjqt.qr>
In-Reply-To: <Pine.LNX.4.61.0705180825280.3231@yvahk01.tjqt.qr>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705181347.14256.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Engelhardt <jengelh@linux01.gwdg.de>
Cc: Rik van Riel <riel@redhat.com>, righiandr@users.sourceforge.net, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I do not see such on i386, so why for x86_64?

So that you know that one of your programs crashed. That's a feature.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
