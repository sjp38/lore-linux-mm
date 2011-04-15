Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 64795900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 16:06:58 -0400 (EDT)
From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: [PATCH V8 1/8] mm/fs: cleancache documentation
References: <67d72d8f-9809-4e43-9e90-417d4eb14db1@default>
Date: Sat, 16 Apr 2011 05:06:45 +0900
In-Reply-To: <67d72d8f-9809-4e43-9e90-417d4eb14db1@default> (Dan Magenheimer's
	message of "Fri, 15 Apr 2011 12:37:11 -0700 (PDT)")
Message-ID: <87ipuf46ui.fsf@devron.myhome.or.jp>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Chris Mason <chris.mason@oracle.com>, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger.kernel@dilger.ca, tytso@mit.edu, mfasheh@suse.com, jlbec@evilplan.org, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, hch@infradead.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, Dave Mccracken <dave.mccracken@oracle.com>, riel@redhat.com, avi@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>, mel@csn.ul.ie, yinghan@google.com, gthelen@google.com, torvalds@linux-foundation.org

Dan Magenheimer <dan.magenheimer@oracle.com> writes:

>> Well, anyway, I guess force enabling this for mostly unused sb can just
>> add cache-write overhead and call for unpleasing reclaim to backend
>> (because of limited space of backend) like updatedb.
>
> If the sb is mostly unused, there should be few puts.  But you
> are correct that if the backend has only very limited space,
> cleancache adds cost and has little value.  On these systems,
> cleancache should probably be disabled.  However, the cost
> is very small so leaving it enabled may not even show a
> measureable performance impact.

Ah, mostly unused sb meant read once for all data pages on that sb for
each few days (updatedb might be wrong example, because it's meta
data. Umm... maybe likely example is backup process). I guess it will be
"put" all pages into backend, and would "flush" useful caches. So, I
think overhead and reclaim pressure are noticeable impact.

Ok, but if now it's concentrating on interface for backend of this, I
think it can be later.

>> And already there is in FAQ though, I also have interest about async
>> interface because of SDD backend (I'm not sure for now though). Is
>> there any plan like SSD backend?
>
> Yes, I think an SSD backend is very interesting, especially
> if the SSD is "very near" to the processor so that it can
> be used as a RAM extension rather than as an I/O device.
>
> The existing cleancache hooks will work for this and I am
> working on a cleancache backend called RAMster that will
> be a good foundation to access other asynchronous devices.
> See: http://marc.info/?l=linux-mm&m=130013567810410&w=2 

Thanks for info.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
