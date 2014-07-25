Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5CF166B0038
	for <linux-mm@kvack.org>; Fri, 25 Jul 2014 11:07:23 -0400 (EDT)
Received: by mail-qa0-f47.google.com with SMTP id i13so4648307qae.6
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 08:07:23 -0700 (PDT)
Received: from service87.mimecast.com (service87.mimecast.com. [91.220.42.44])
        by mx.google.com with ESMTP id b7si16762382qai.88.2014.07.25.08.07.22
        for <linux-mm@kvack.org>;
        Fri, 25 Jul 2014 08:07:22 -0700 (PDT)
From: "Wilco Dijkstra" <wdijkstr@arm.com>
Subject: Background page clearing
Date: Fri, 25 Jul 2014 16:06:51 +0100
Message-ID: <000001cfa81a$110d15c0$33274140$@com>
MIME-Version: 1.0
Content-Language: en-gb
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi,

I recently noticed how a Stream benchmark took 30% more time in the first i=
teration due to having to
clean pages in the output array. Especially clearing a huge page on a pagef=
ault is a substantial
overhead. It affects the cached data of the workload while it is running an=
d reduces available
memory bandwidth.

Is there a reason Linux does not do background page clearing like other OSe=
s to reduce this
overhead? It would be a good fit for typical mobile workloads (bursts of hi=
gh activity followed by
periods of low activity).

Wilco



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
