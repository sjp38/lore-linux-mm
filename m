Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6EC106B0005
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 02:30:12 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id h144so95221559ita.1
        for <linux-mm@kvack.org>; Sun, 05 Jun 2016 23:30:12 -0700 (PDT)
Received: from SNT004-OMC3S34.hotmail.com (snt004-omc3s34.hotmail.com. [65.55.90.173])
        by mx.google.com with ESMTPS id 62si8221859ots.136.2016.06.05.23.30.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 05 Jun 2016 23:30:11 -0700 (PDT)
From: =?iso-8859-2?Q?Rados=B3aw_Smogura?= <mail@smogura.eu>
Subject: Hugepages for tmpfs
Date: Mon, 6 Jun 2016 06:30:06 +0000
Message-ID: <0B540039-9A94-43F8-9C16-EE04F68646AF@smogura.eu>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-2"
Content-ID: <0A8DD2BDA1C55F45BFA21087D09EA062@eurprd03.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi all,

Long time ago I was working on enabling huge pages for tmpfs and in terms f=
or any filesystem. Recently I have found my work and I was thinking about r=
estarting it with new kernel.

I wonder if there is some ongoing or finished work for huge pages in tmpfs?

Best regards,
Radek Smogura=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
