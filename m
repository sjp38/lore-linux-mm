Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7FDF08D0039
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 07:04:20 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 00AFA3EE0AE
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:04:16 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D86F445DE5A
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:04:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C09E045DE58
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:04:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B348DE08004
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:04:15 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D0ACE08001
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:04:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [patch 0/5] oom: a few anti fork bomb patches
In-Reply-To: <20110315153801.3526.A69D9226@jp.fujitsu.com>
References: <20110314232156.0c363813.akpm@linux-foundation.org> <20110315153801.3526.A69D9226@jp.fujitsu.com>
Message-Id: <20110322194721.B05E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="------_4D887E3900000000B05A_MULTIPART_MIXED_"
Content-Transfer-Encoding: 7bit
Date: Tue, 22 Mar 2011 20:04:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--------_4D887E3900000000B05A_MULTIPART_MIXED_
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit

Hi

I'm backed. Andrey's (attached) fork bomb testcase effectively kill
my machine when swap is disabled. therefore, I've made a few anti andrey
test patches.

This patches only avoid kernel livelock. they doesn't genocide fork-bombs.
Kamezawa-san is trying such effort.

comments are welcome.

--------_4D887E3900000000B05A_MULTIPART_MIXED_
Content-Type: application/octet-stream;
 name="memeater.py"
Content-Disposition: attachment;
 filename="memeater.py"
Content-Transfer-Encoding: base64

aW1wb3J0IHN5cywgdGltZSwgbW1hcCwgb3MNCmZyb20gc3VicHJvY2VzcyBpbXBvcnQgUG9wZW4s
IFBJUEUNCmltcG9ydCByYW5kb20NCg0KZ2xvYmFsIG1lbV9zaXplDQoNCmRlZiBpbmZvKG1zZyk6
DQoJcGlkID0gb3MuZ2V0cGlkKCkNCglwcmludCA+PiBzeXMuc3RkZXJyLCAiJXM6ICVzIiAlIChw
aWQsIG1zZykNCglzeXMuc3RkZXJyLmZsdXNoKCkNCg0KDQoNCmRlZiBtZW1vcnlfbG9vcChjbWQg
PSAiYSIpOg0KCSIiIg0KCWNtZCBtYXkgYmU6DQoJCWM6IGNoZWNrIG1lbW9yeQ0KCQllbHNlOiB0
b3VjaCBtZW1vcnkNCgkiIiINCgljID0gMA0KCWZvciBqIGluIHhyYW5nZSgwLCBtZW1fc2l6ZSk6
DQoJCWlmIGNtZCA9PSAiYyI6DQoJCQlpZiBmW2o8PDEyXSAhPSBjaHIoaiAlIDI1NSk6DQoJCQkJ
aW5mbygiRGF0YSBjb3JydXB0aW9uIikNCgkJCQlzeXMuZXhpdCgxKQ0KCQllbHNlOg0KCQkJZltq
PDwxMl0gPSBjaHIoaiAlIDI1NSkNCg0Kd2hpbGUgVHJ1ZToNCglwaWQgPSBvcy5mb3JrKCkNCglp
ZiAocGlkICE9IDApOg0KCQltZW1fc2l6ZSA9IHJhbmRvbS5yYW5kaW50KDAsIDU2ICogNDA5NikN
CgkJZiA9IG1tYXAubW1hcCgtMSwgbWVtX3NpemUgPDwgMTIsIG1tYXAuTUFQX0FOT05ZTU9VU3xt
bWFwLk1BUF9QUklWQVRFKQ0KCQltZW1vcnlfbG9vcCgpDQoJCW1lbW9yeV9sb29wKCJjIikNCgkJ
Zi5jbG9zZSgpDQo=
--------_4D887E3900000000B05A_MULTIPART_MIXED_--


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
