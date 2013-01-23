From: Christoph Lameter <cl@linux.com>
Subject: FIX [0/2] Slub hot path fixes
Date: Wed, 23 Jan 2013 21:45:47 +0000
Message-ID: <0000013c695fbbe8-6a7f750f-4647-40b8-9ab3-f4fa5af8c382-000000@email.amazonses.com>
Return-path: <linux-rt-users-owner@vger.kernel.org>
Sender: linux-rt-users-owner@vger.kernel.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, RT <linux-rt-users@vger.kernel.org>, Clark Williams <clark@redhat.com>, John Kacur <jkacur@gmail.com>, "Luis Claudio R. Goncalves" <lgoncalv@redhat.com>, Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com
List-Id: linux-mm.kvack.org

These are patches to fix up the issues brought up by Steven Rostedt.

I hoped to avoid the preempt disable for the tid retrieval but there is
no per cpu atomic way to get a value from the per cpu area and also retrieve
the pointer used in that operation. The pointer is necessary to fetch the
related data from the per cpu structure. Without that we
run into more issues with page pointer checks that can cause
freelist corruption in slab_free().

