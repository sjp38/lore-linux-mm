Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id D4B0C6B0007
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 17:19:43 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id w2-v6so1924616qti.8
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 14:19:43 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id g4si2953167qka.106.2018.04.18.14.19.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 14:19:42 -0700 (PDT)
Date: Wed, 18 Apr 2018 17:19:39 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: [LSF/MM] schedule suggestion
Message-ID: <20180418211939.GD3476@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

Just wanted to suggest to push HMM status down one slot in the
agenda to avoid having FS and MM first going into their own
room and then merging back for GUP and DAX, and re-splitting
after. More over HMM and NUMA talks will be good to have back
to back as they deal with same kind of thing mostly.

So on Monday afternoon GUP in first slot would be nice :)

Just a suggestion

https://docs.google.com/spreadsheets/d/15XFz_Zsklmle--L9CO4-ygCqmSHwBsFPjvjDpiL5qwM/edit#gid=0

Cheers,
Jerome
