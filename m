Message-Id: <000901bee855$ec448410$0601a8c0@honey.cs.tsinghua.edu.cn>
From: "Wang Yong" <wung_y@263.net>
Subject: where does vmlist be initiated?
Date: Tue, 17 Aug 1999 10:12:10 +0800
Mime-Version: 1.0
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm mail list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

hi,
  i found this structure is defined in mm/vmalloc.c :
  "static struct vm_struct * vmlist = NULL;"

  it appears that vmlist be initiated as null. but in function
get_vm_area(), which is called by kmalloc(), it doesn't work if vmlist is
null. so i think vmlist must be initiated somewhere else. but where? thx

regards,
Wang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
