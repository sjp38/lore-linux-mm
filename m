Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 34F356B006C
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 13:29:40 -0400 (EDT)
Received: by oagk14 with SMTP id k14so8181836oag.14
        for <linux-mm@kvack.org>; Tue, 02 Oct 2012 10:29:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <506A4100.7070305@jp.fujitsu.com>
References: <1346837155-534-1-git-send-email-wency@cn.fujitsu.com>
 <1346837155-534-2-git-send-email-wency@cn.fujitsu.com> <506509E4.1090000@gmail.com>
 <50651E68.3040208@jp.fujitsu.com> <CAHGf_=oJ_Jmjqcdr4cPJghf7PX+vfmZe=CV2sdQQhS5agzG15w@mail.gmail.com>
 <506A4100.7070305@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 2 Oct 2012 13:29:19 -0400
Message-ID: <CAHGf_=rNSmtxw2JL2g+b-yq9KTFZPWBp90KtERJouDS-vv3zWw@mail.gmail.com>
Subject: Re: [RFC v9 PATCH 01/21] memory-hotplug: rename remove_memory() to offline_memory()/offline_pages()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Ni zhan Chen <nizhan.chen@gmail.com>, wency@cn.fujitsu.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org

>> Then, you introduced bisect breakage. It is definitely unacceptable.
>
> What is "bisect breakage" meaning?

Think what's happen when only applying path [1/21].

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
