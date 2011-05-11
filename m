Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 661216B0023
	for <linux-mm@kvack.org>; Wed, 11 May 2011 13:19:01 -0400 (EDT)
Received: by qwa26 with SMTP id 26so559736qwa.14
        for <linux-mm@kvack.org>; Wed, 11 May 2011 10:18:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <cover.1305132792.git.minchan.kim@gmail.com>
References: <cover.1305132792.git.minchan.kim@gmail.com>
Date: Thu, 12 May 2011 02:18:59 +0900
Message-ID: <BANLkTi=DmTDgDNW0sEgQPeL7YtdT6SG-dg@mail.gmail.com>
Subject: Re: [PATCH v1 00/10] Prevent LRU churning
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: multipart/mixed; boundary=002354470c8cae6d8a04a303445e
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

--002354470c8cae6d8a04a303445e
Content-Type: text/plain; charset=UTF-8

I missed script used for testing.
Attached.



-- 
Kind regards,
Minchan Kim

--002354470c8cae6d8a04a303445e
Content-Type: application/x-sh; name="run-many-x-apps.sh"
Content-Disposition: attachment; filename="run-many-x-apps.sh"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gnkj9i2n0

IyEvYmluL3pzaAoKcmVhZCBUMCBUMSA8IC9wcm9jL3VwdGltZQoKZnVuY3Rpb24gcHJvZ3Jlc3Mo
KQp7CglyZWFkIHQwIHQxIDwgL3Byb2MvdXB0aW1lCgl0PSQoKHQwIC0gVDApKQoJcHJpbnRmICIl
OC4yZiAgICAiICR0CgllY2hvICIkQCIKfQoKZnVuY3Rpb24gc3dpdGNoX3dpbmRvd3MoKQp7Cgl3
bWN0cmwgLWwgfCB3aGlsZSByZWFkIGEgYiBjIHdpbgoJZG8KCQlwcm9ncmVzcyBBICIkd2luIgoJ
CXdtY3RybCAtYSAiJHdpbiIKCWRvbmUKfQoKd2hpbGUgcmVhZCBhcHAgYXJncwpkbwoJcHJvZ3Jl
c3MgTiAkYXBwICRhcmdzCgkkYXBwICRhcmdzICYKCXN3aXRjaF93aW5kb3dzCmRvbmUgPDwgRU9G
CnhleWVzCmZpcmVmb3gKbmF1dGlsdXMKbmF1dGlsdXMgLS1icm93c2VyCmd0aHVtYgpnZWRpdAoK
eHRlcm0KbWx0ZXJtCmdub21lLXRlcm1pbmFsCgpnbm9tZS1zeXN0ZW0tbW9uaXRvcgpnbm9tZS1o
ZWxwCmdub21lLWRpY3Rpb25hcnkKCi91c3IvZ2FtZXMvc29sCi91c3IvZ2FtZXMvZ25vbWV0cmlz
Ci91c3IvZ2FtZXMvZ25lY3QKL3Vzci9nYW1lcy9ndGFsaQovdXNyL2dhbWVzL2lhZ25vCi91c3Iv
Z2FtZXMvZ25vdHJhdmV4Ci91c3IvZ2FtZXMvbWFoam9uZ2cKL3Vzci9nYW1lcy9nbm9tZS1zdWRv
a3UKL3Vzci9nYW1lcy9nbGluZXMKL3Vzci9nYW1lcy9nbGNoZXNzCi91c3IvZ2FtZXMvZ25vbWlu
ZQovdXNyL2dhbWVzL2dub3Rza2kKL3Vzci9nYW1lcy9nbmliYmxlcwovdXNyL2dhbWVzL2dub2Jv
dHMyCi91c3IvZ2FtZXMvYmxhY2tqYWNrCi91c3IvZ2FtZXMvc2FtZS1nbm9tZQoKL3Vzci9iaW4v
Z25vbWUtd2luZG93LXByb3BlcnRpZXMKL3Vzci9iaW4vZ25vbWUtZGVmYXVsdC1hcHBsaWNhdGlv
bnMtcHJvcGVydGllcwovdXNyL2Jpbi9nbm9tZS1hdC1wcm9wZXJ0aWVzCi91c3IvYmluL2dub21l
LXR5cGluZy1tb25pdG9yCi91c3IvYmluL2dub21lLWF0LXZpc3VhbAovdXNyL2Jpbi9nbm9tZS1z
b3VuZC1wcm9wZXJ0aWVzCi91c3IvYmluL2dub21lLWF0LW1vYmlsaXR5Ci91c3IvYmluL2dub21l
LWtleWJpbmRpbmctcHJvcGVydGllcwovdXNyL2Jpbi9nbm9tZS1hYm91dC1tZQovdXNyL2Jpbi9n
bm9tZS1kaXNwbGF5LXByb3BlcnRpZXMKL3Vzci9iaW4vZ25vbWUtbmV0d29yay1wcmVmZXJlbmNl
cwovdXNyL2Jpbi9nbm9tZS1tb3VzZS1wcm9wZXJ0aWVzCi91c3IvYmluL2dub21lLWFwcGVhcmFu
Y2UtcHJvcGVydGllcwovdXNyL2Jpbi9nbm9tZS1jb250cm9sLWNlbnRlcgovdXNyL2Jpbi9nbm9t
ZS1rZXlib2FyZC1wcm9wZXJ0aWVzCgpvb2NhbGMKb29kcmF3Cm9vaW1wcmVzcwpvb21hdGgKb293
ZWIKb293cml0ZXIgICAgCgplY2xpcHNlCmdpbXAKRU9GCg==
--002354470c8cae6d8a04a303445e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
