Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id AD64C6B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 09:42:58 -0500 (EST)
Received: by vbbey12 with SMTP id ey12so3279581vbb.14
        for <linux-mm@kvack.org>; Wed, 29 Feb 2012 06:42:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <87ty29ew8h.fsf@linux.vnet.ibm.com>
References: <1330280398-27956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<20120227151135.7d4076c6.akpm@linux-foundation.org>
	<87ipirclhe.fsf@linux.vnet.ibm.com>
	<CAJd=RBA05LqrUohAfO43ywZR_xwi4KygpzZP2zun=taKTLCvnQ@mail.gmail.com>
	<87ty29ew8h.fsf@linux.vnet.ibm.com>
Date: Wed, 29 Feb 2012 22:42:57 +0800
Message-ID: <CAJd=RBA+7Hvwxz4kr9_bx0q4AqzEkaUo4pLnv-scGCeVB5puPg@mail.gmail.com>
Subject: Re: [PATCH] hugetlbfs: Add new rw_semaphore to fix truncate/read race
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, hughd@google.com, linux-kernel@vger.kernel.org

On Wed, Feb 29, 2012 at 7:04 PM, Aneesh Kumar K.V
<aneesh.kumar@linux.vnet.ibm.com> wrote:
> I guess we need to closely look at the patch with respect to end-of-file

Feel free to correct Hillf:)

> condition. I will also try to get some testing with the patch.
>
Look forward to seeing test results.

Best regards
-hd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
