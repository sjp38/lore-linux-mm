Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F01516B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 16:25:01 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s70so166329712pfs.5
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 13:25:01 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id u10si8462398pfi.252.2017.07.25.13.24.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 13:24:58 -0700 (PDT)
Date: Tue, 25 Jul 2017 16:24:34 -0400
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH updated 14/23] percpu: replace area map allocator with bitmap
Message-ID: <20170725202434.GA56441@dennisz-mbp.dhcp.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170724230220.21774-15-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Josef Bacik <josef@toxicpanda.com>, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, kernel-team@fb.com, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

