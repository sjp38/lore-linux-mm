Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 22B376B005D
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 17:12:50 -0400 (EDT)
Received: by obhx4 with SMTP id x4so51225obh.14
        for <linux-mm@kvack.org>; Fri, 07 Sep 2012 14:12:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALF0-+XHSaZW_mBq_WQAmxOTK46zXx1gEx-wX6Ho1BAskGmhmQ@mail.gmail.com>
References: <1346885323-15689-1-git-send-email-elezegarcia@gmail.com>
	<1346885323-15689-3-git-send-email-elezegarcia@gmail.com>
	<alpine.DEB.2.00.1209051757250.7625@chino.kir.corp.google.com>
	<CALF0-+WgAicBOv6beNdfkFFS-DuAZMQfH9r9iYG5tkfFNSzRZg@mail.gmail.com>
	<CAAmzW4NOMyZ8GPb7NcJBvcRD55JTFRhVxG7yyo29YcRWKm3mwA@mail.gmail.com>
	<CALF0-+XHSaZW_mBq_WQAmxOTK46zXx1gEx-wX6Ho1BAskGmhmQ@mail.gmail.com>
Date: Sat, 8 Sep 2012 06:12:49 +0900
Message-ID: <CAAmzW4P0AgxO6cgspO3R6641fw1+9u9aC8pHfphRDESfJjLrYg@mail.gmail.com>
Subject: Re: [PATCH 3/5] mm, util: Do strndup_user allocation directly,
 instead of through memdup_user
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

Hi, Ezequiel.

2012/9/7 Ezequiel Garcia <elezegarcia@gmail.com>:
>> But, if you want to fix this properly, why don't change __krealloc() ?
>> It is called by krealloc(), and may return krealloc()'s address.
>
> That's already fixed and applied on Pekka's tree, it's this one:
> mm: Use __do_krealloc to do the krealloc job

Okay. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
