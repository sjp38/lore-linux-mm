Message-ID: <20000308020520.18155.qmail@web1306.mail.yahoo.com>
Date: Tue, 7 Mar 2000 18:05:20 -0800 (PST)
From: Andy Henroid <andy_henroid@yahoo.com>
Subject: remap_page_range problem on 2.3.x
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="0-846930886-952481120=:17909"
Sender: owner-linux-mm@kvack.org
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

For the ACPI driver, I'm trying to map a chunk of
kmalloced memory into userspace (via mmap on /dev/mem)
The remap_page_range succeeds but what is mapped is
just a page of zeros and not the kmalloced data.

Attached is a tiny kernel module and app to reproduce
the problem on 2.3.49.  Or am I doing something stupid
here?

Thank you,
Andy Henroid
andy_henroid@yahoo.com






__________________________________________________
Do You Yahoo!?
Talk to your friends online with Yahoo! Messenger.
http://im.yahoo.com
--0-846930886-952481120=:17909
Content-Type: application/x-gzip-compressed; name="mmtest.tar.gz"
Content-Transfer-Encoding: base64
Content-Description: mmtest.tar.gz
Content-Disposition: attachment; filename="mmtest.tar.gz"

H4sICAyxxTgCA21tdGVzdC50YXIA7Rdrb6NG0F/hV6xySQWuifEjTuU8dFbs
RFHtJPIlPVXXEyKwOMiwWAtETqv+984+wOBwl3xJrq2YDzbMe2dmZ4YwTHCc
tBtvCahvHh4eoAZC6HDQL/1LMAFjDjq9nml2ewh1OoNup4EOGu8AaZzYFKHG
AyY08t1v8r1E/49CKPI/s5fY8wP8JjY6pjnYynsp//3Dgcx/t9vt9yH/vd5B
r4HMOv9vDr9O5leTqXV5dTa9G0/Q8AS105i2Y+q0A5+k67ZPnCB1saqenaET
tHAceDqfji4+MV7jsx0EyPBIZMQJxWSRPBgUu6mDARmFfmJ41A6xsYp8kmBa
kNzVxLOOjLFlSS8seJldj++mE2Rc7mpl3/RqaeHBZ/AgJWmMXfEcpkHiOw82
VVWgD5Eo8/1IPoAravY0zHH7jqqA5jPQukBGhHY/ot1jVXUCbJMhI81nes6M
mvuR+r+5/zI+zo+4/93eIL//A/PAZPcfJkZ9/98DPsj7jY7FdQ8jNw3w/sOp
uk3xiZ9U4ZeYEhxUUVY0ciwvZiT1gwvzhWA0m91OPt1as9HF5VkHmWsX2+49
xl4lQxcYPIwZg6uqkCi40wgaTeokiCt3fWphktAn1BQVbDE09Kmru+n0KJNI
e92c7tqJndMzBmhO8l5bD8QNOJPGugdqruwFbqmKorBKFagmq5gkR0aeZyXs
N8YbJNPoRCkpY5o48nLEI1QTajJTuvqXqgituWsK44W3zpGajUmKk5QSFK8o
6PI07hnaMdd7wfoPstNClrWytcIxdf1I/bvqjCyTGjPPDZcDswyhX0aOBhFD
sf8nOKFB+PQWuji/kW0a1Cq+h0qmVAU0FVV9Mb+CtlK2j7Y4OtscXcbBT7fk
vR86//k12hEyQ8Q9/AglsWf+Io6sikgCVJ39RV1c01r+lfWVT9JCZb+Zcois
Uq45XpHhEmpSk3YgKRxJowhkqf+I6VbwGFkG7xt1zf9YzZwgh2I7wVxGULUd
5hBYMXMPuUJ2dmaEM+lMmD8Zp6DAzdzdLnh+JkUWmVksHV6pkh2vi7VDcRg9
Vnq05U4F4/dCVFVgytKjGJeQ3EnRsURRFwociJLCXS64D5RGDVXzn61AP2D+
H3T6+fzvd7ps/h/26v3/ned//BS3k6cVjsujnKFZH3iODUOblLGeQ5KtTSAl
fpy4W8KJ60fPUIF/v42D9r0o4zClhIuq0NnV0PaJxgabTRdOKxvP8PLIuxOj
eC50H064Tz0P0y+97lfApCT2FwS+FoKILJDturQlR3iRKBSG9mqF3SK+Kfql
qnguNNJohYm2w7edtuhg8jq1ZS+8tubj66vp71nvB6ljZMq278lxDhGAw7Wy
EcW+S5jiIdqL+XRn31eURlTjIRDzjXe2jphGXDPr76C+JQ/byka4eNX119ll
Wl5v1wmiGINR3rZZJCEkIJREaaBlbrCdBqYUkxBRBh7O+hPSFjhhqwzzVIMv
L8T1SucKThWnv9h3mIJqXqZPprMoIDD6duJc/NgOcfheiYK1gRcUH8H2SuOx
yTePUjQ26Jv59a01n4zGG9RsdGPdzC9/G91ONkjIff7MA2xsTi1mqrR9wuXP
R5fTyfjlAzJHX18RcpXUsvvS1DOzPxdz8DxvoWSTi5lxWtrNUMWxYNHgIt+p
GaFiWLXtSY2MrYXyXW+z5EGqUsJyJIy0ytnhDMV9qd4maqihhhpqqKGGGmqo
oYYaaqihhhpq+LfBP4Oxa1kAKAAA

--0-846930886-952481120=:17909--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
