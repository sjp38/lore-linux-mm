Message-ID: <464C9D82.60105@redhat.com>
Date: Thu, 17 May 2007 14:22:58 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] log out-of-virtual-memory events
References: <464C81B5.8070101@users.sourceforge.net>
In-Reply-To: <464C81B5.8070101@users.sourceforge.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: righiandr@users.sourceforge.net
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Righi wrote:
> I'm looking for a way to keep track of the processes that fail to allocate new
> virtual memory. What do you think about the following approach (untested)?

Looks like an easy way for users to spam syslogd over and
over and over again.

At the very least, shouldn't this be dependant on print_fatal_signals?

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
