Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 6D7DF6B0078
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 18:50:48 -0400 (EDT)
Received: by iec9 with SMTP id 9so2458550iec.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 15:50:47 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 5 Sep 2012 19:50:47 -0300
Message-ID: <CALF0-+ViKZe=QoNYqz_vyoQc5kH1EJ5K5M=HfGdvOFjnWY1BbA@mail.gmail.com>
Subject: [PATCH 0/5] mm, slob: Tracing accuracy improvement
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Glauber Costa <glommer@parallels.com>, Tim Bird <tim.bird@am.sony.com>, Steven Rostedt <rostedt@goodmis.org>

Hi everyone,

This small patchset improves mm tracing accuracy, particularly on the
slob allocator.
Feedback, comments, suggestions are very welcome.

This work is part of CELF Workgroup Project:
"Kernel_dynamic_memory_allocation_tracking_and_reduction" [1]

Ezequiel Garcia (5):
 mm, slob: Trace allocation failures consistently
 mm, slob: Use only 'ret' variable for both slob object and returned pointer
 mm, util: Do strndup_user allocation directly, instead of through memdup_user
 mm, slob: Add support for kmalloc_track_caller()
 mm, slab: Remove silly function slab_buffer_size()

 include/linux/slab.h |    6 +++-
 mm/slab.c            |   12 +--------
 mm/slob.c            |   62 +++++++++++++++++++++++++++++++++++--------------
 mm/util.c            |   15 +++++++++--
 4 files changed, 62 insertions(+), 33 deletions(-)

Thanks!
Ezequiel.

[1] http://elinux.org/Kernel_dynamic_memory_allocation_tracking_and_reduction

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
