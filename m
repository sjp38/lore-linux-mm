Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 598CF6B004A
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 04:33:23 -0400 (EDT)
Received: by obbeh20 with SMTP id eh20so5539063obb.14
        for <linux-mm@kvack.org>; Wed, 18 Apr 2012 01:33:22 -0700 (PDT)
Date: Wed, 18 Apr 2012 01:32:08 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH v2 0/2] vmevent: Greater-than attribute + one-shot mode + a
 bugfix
Message-ID: <20120418083208.GA24904@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org

Hi all,

That's a respin of the previous patchset that tried to add a new
'cross' event type, which would trigger whenever value crosses a
user-specified threshold both ways, i.e. from a lesser values side
to a greater values side, and vice versa.

We use the event type in an userspace low-memory killer: we get a
notification when memory becomes low, so we start freeing memory by
killing unneeded processes, and we get notification when memory hits
the threshold from another side, so we know that we freed enough of
memory.

There's also a fix for a bug that makes kernel upset about sleeping
in the atomic context.

Per Pekka's comments here comes v2. Changes:

- Added a one-shot mode plus a greater-than attribute, the two
  additions makes the equivalent of the cross-event type.
- In the bugfix patch I added some comments about implementation
  details of the lock-free logic. Also, in the previous version of
  the fix I forgot to remove 'struct mutex' form the
  'struct vmevent_watch', this is now cleaned up.

As usual, the patches are against

	git://github.com/penberg/linux.git vmevent/core

Thanks!

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
