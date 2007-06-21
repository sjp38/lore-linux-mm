From: Christoph Lameter <clameter@sgi.com>
Subject: NUMA BOF @OLS
Date: Thu, 21 Jun 2007 13:24:36 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0706211316150.9220@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759894AbXFUUYs@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

Everyone is invited to the NUMA BOF at the Ottawa Linux Symposium

Friday Jun 29th, 2007 19:00 - 20:00 in Rockhopper

The main interest seems to be a discussion on the use of memory policies. 
Lee Schermerhorn will talk a bit about his work and then I may say 
something about the problems with memory policies.

More subjects:

- Memoryless node support

- Restricting subsystems to not allocate on certain nodes
  (f.e. huge pages only on some nodes, slab only on some nodes,
  kernel memory only on some nodes).

- Cpusets and containers

- Do we need to have more support for multicore issues in the NUMA layers?

- Issues with the scheduler on NUMA. 

If you have another subject that should be brought up then please contact 
me.
