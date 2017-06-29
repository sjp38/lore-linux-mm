Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 07BC16B02C3
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 10:56:43 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id j186so90549919pge.12
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 07:56:42 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id d22si4167031plj.415.2017.06.29.07.56.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 07:56:42 -0700 (PDT)
Date: Thu, 29 Jun 2017 10:56:26 -0400
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH 1/1] percpu: fix static checker warnings in pcpu_destroy_chunk
Message-ID: <20170629145625.GA79969@dennisz-mbp>
References: <20170629110954.uz6he7x25bg4n3pp@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170629110954.uz6he7x25bg4n3pp@mwanda>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, linux-mm@kvack.org

