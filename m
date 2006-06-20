Message-ID: <44985E9E.1070603@google.com>
Date: Tue, 20 Jun 2006 13:46:22 -0700
From: Martin Bligh <mbligh@google.com>
MIME-Version: 1.0
Subject: zoned-vm-stats-add-nr_anon.patch
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Could we rename nr_mapped to something else if we're going to change
it's meaning? Perhaps split nr_mapped into nr_mapped_file and
nr_mapped_anon or something?

Otherwise any poor schmuck (eg me) who has to work across different
kernel versions is going to get rather confused in the future.

In my mind, "nr_mapped" is a good name for the number of pages which
are mapped, so excluding the anon pages from that seems to make
the naming non-obvious. similarly, I presume we can have anon pages
on transition to or from swap that are not mapped, and yet will
not be reflected here, so nr_anon doesn't seem like a wholly
accurate name to me either?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
