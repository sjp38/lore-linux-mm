Date: Mon, 11 Aug 2003 11:02:13 +0200
From: Roger Luethi <rl@hellgate.ch>
Subject: Is /proc/#/statm worth fixing?
Message-ID: <20030811090213.GA11939@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

/proc/#/statm is a joke. Out of 7 columns, 2 are always zero in 2.6. Of
the remaining columns, at least one more is incorrect. You can most
certainly get all the intended values off /proc/#/status anyway [1].

In 2.4, more columns show actual data, but also more of them are wrong.
To top it off, 2.4 and 2.6 show vastly different numbers for several
colums (where they clearly shouldn't).

/proc/#/statm is bust and any tool relying on it is broken. Can we just
remove that file? Maybe print poisoned values in 2.6 to prevent the odd
program from crashing (if there are any), and remove it in 2.7.

Roger

[1] Mind you it's tricky to find out what correct behaviour would be if the
    only documentation you can find has obviously been wrong forever.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
