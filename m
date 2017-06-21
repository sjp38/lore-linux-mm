Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7F3D86B0343
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 13:53:10 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 4so17246876wrc.15
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 10:53:10 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id q3si17235567wrd.188.2017.06.21.10.53.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 10:53:08 -0700 (PDT)
Date: Wed, 21 Jun 2017 13:52:46 -0400
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH 1/1] percpu: fix early calls for spinlock in pcpu_stats
Message-ID: <20170621175245.GA99514@dennisz-mbp.dhcp.thefacebook.com>
References: <20170619232832.27116-1-dennisz@fb.com>
 <20170619232832.27116-5-dennisz@fb.com>
 <20170621161836.tv67op4hokja35bc@sasha-lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170621161836.tv67op4hokja35bc@sasha-lappy>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>, Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kernel-team@fb.com" <kernel-team@fb.com>

